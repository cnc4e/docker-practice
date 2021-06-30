[TOP](../README.md)   
前: -  
次: [サービスのヘルスチェック](./swarm-service-healthcheck.md)  

---

`本プラクティスはAWSを前提とした手順になっています。`

# ログ

コンテナのログはコンテナが停止すると失われます。異常終了などした場合、原因調査する際にログがないのはとても大変です。そのため、コンテナのログを外部の領域に保存する仕組みが必要となります。

本プラクティスではコンテナ界隈でよく使用される[Fluentd](https://www.fluentd.org/)というログ収集ツールを使用したログ収集の仕組みを実装します。（類似の製品としてはFluentdbit、Logstashなどもあります。）　また、Dockerはコンテナのログを出力する方法をロギングドライバで指定できます。ロギングドライバにはさまざまな種類があり、たとえばデフォルトの`json-file`はコンテナのログをjsonファイルの形式でホスト内の所定のディレクトリに出力します。今回使用するFluentdもロギングドライバとして用意されているためコンテナログをそのままFluentdへ連携できます。対応しているロギングドライバの一覧は[こちら](https://docs.docker.com/config/containers/logging/configure/#supported-logging-drivers)を参照ください。（なお、20.10より前のDockerではロギングドライバでFluentdなどを選択すると無償版のエディションではdocker logsコマンドが実行できませんでした。20.10以降はデュアルロギングに対応したためFluentdを選択してもdocker logsが実行できるようになりました。[ネタ元](https://docs.docker.com/config/containers/logging/dual-logging/)）

今回はFluentdで収集したログをAWSのCloudWatch Logsに保管します。Fluentdには機能を拡張するプラグインが豊富に用意されています。CloudWatch Logsへログを保管する機能もプラグインとして用意されているためそれを使用します。

## 1. Fluentdイメージの準備

CloudWatch Logsへログを保管したいためプラグインをインストールしたコンテナイメージを用意します。すでにビルド済のイメージを`ryotamori/fluentd-cloudwatch:v1.9-1`で公開しています。（作成者のDocker Hubです。）

以下、イメージをビルドした時の手順です。他のプラグインをインストールしたい場合やベースイメージを変えたい場合など参考にしてください。

### 1-1. ビルド手順

CloudWatch Logsへログを保管するプラグインは[fluent-plugin-cloudwatch-logs](https://github.com/fluent-plugins-nursery/fluent-plugin-cloudwatch-logs)で公開されてます。

Fluentd公式のGitHubにイメージをカスタマイズする方法が載っています。[これ](https://github.com/fluent/fluentd-docker-image#3-customize-dockerfile-to-install-plugins-optional)

上記のDockerfileをカスタマイズして`fluent-plugin-cloudwatch-logs`をインストールします。ベースのイメージは作業時最新の`fluentd:v1.9-1`を使います。

``` Docker
FROM fluent/fluentd:v1.9-1

# Use root account to use apk
USER root

RUN apk add --no-cache --update --virtual .build-deps \
        sudo build-base ruby-dev \
 && sudo gem install fluent-plugin-cloudwatch-logs \
 && sudo gem sources --clear-all \
 && apk del .build-deps \
 && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem
```

上記作成したDockerfileをbuild&pushします。

``` sh
docker build -t ryotamori/fluentd-cloudwatch:v1.9-1 .
docker push ryotamori/fluentd-cloudwatch:v1.9-1
```

## 2. インスタンスのIAMロール

DockerホストにCloudWatch Logsを操作するためのIAMポリシーをアタッチしてください。たとえば`CloudWatchLogsFullAccess`がついていれば十分です。

## 3. Fluentdのデプロイ

Fluentdをデプロイします。まずはFluentdの設定ファイルを作成します。続いて、Fluentdはすべてのworkerに配置したいためglobalでデプロイします。また、各workerで動いているコンテナログの収集は同じworkerで動いているFluentdにやらせたいです。（わかりやすいかなと思ったのですが好みかもしれません。）　そのためFluentdタスクはホストモードでポート公開します。

### 3-1. Fluent.confの準備

今回使用するFluentdのイメージではログ収集の設定を`/fluentd/etc/fluent.conf`に記述します。デフォルトのfluent.confにはCloudWatch Logsへ転送するための設定は記述されていません。CloudWatch Logsへ転送する設定を記述したfluent.confを準備します。（後ほどの手順でconfigにしてコンテナにマウントさせます。）

1. 以下内容の`fluent.conf`ファイルを作成してください。`<リージョン>`は自身の環境に合わせてください。

```
<source>
  @type  forward
  @id    input1
  @label @mainstream
  port  24224
</source>

<filter **>
  @type stdout
</filter>

<label @mainstream>
  <match docker.**>
    @type cloudwatch_logs
    log_group_name docker-practice
    auto_create_stream true
    region <リージョン>
    use_tag_as_stream true
  </match>
</label>
```

上記ファイルの内容を少し解説します。`<source>`ディレクティブではport:24224でログを待ち受ける設定をしています。また、受け取ったログに`@mainstream`ラベルをつけています。`<label @mainstream>`ディレクティブでは`@mainstream`ラベルのついたログに関する処理を記述します。
`<match docker.**>`ディレクティブで`docker.`から始まるタグのついたログを出力する設定を記述しています。`@type cloudwatch_logs`はCloudWatch Logsプラグインの使用を宣言しています。それ以降はプラグインの設定です。プラグインの設定については[こちら](https://github.com/fluent-plugins-nursery/fluent-plugin-cloudwatch-logs#out_cloudwatch_logs)を参照ください。今回は`docker-practice`というロググループ以下に`docker.**`のタグごとにログストリームを作成する設定をしています。（コンテナログに対するタグ付けの設定は後ほどcomposeファイルの中で指定します。）

### 3-2. Fluentdのデプロイ

1. 以下満たすcomposeファイル`fluentd.yaml`を作成してください。

- service: fluentd
  - image: ryotamori/fluentd-cloudwatch:v1.9-1
  - deploy: global
  - ports: コンテナのtcp24224をホストの24224ポートで公開。モードはホストを指定
  - config: config:fluent.confを/fluentd/etc/fluent.confにマウント
- config: fluent.conf
  - source: [Fluent.confの準備](#fluentconfの準備)で作成したfluent.confを指定

> globalで配置するのはなぜですか？  
> 実はreplicatedでも良いです。ですが、今回はやってないですがたとえばホストのsyslogなども収集することを考えるとすべてのworkerに配置した方が良いかなと思いました。

> ホストモードで公開するのはなぜですか？  
> 実は通常のovaerlayネットワークでもよいです。しかし、そうするとコンテナのログが同じworkerノードで動いているFluetndに送らえるとは限りません。別ノードで起動しているFluentdに転送される可能性があります。最終的にCloudWatch Logsに格納するので気にしなくても良い気もします。ですが、たとえばFluentd内のファイルに吐かせる場合、違うノードで動いているコンテナのログがあるのは少し奇妙に思えるかもしれません。

2. 上記作成したcomposeファイルを指定し、スタック`fluentd`を作成してください。

3. スタックの一覧、スタック内のサービス一覧、スタック内のタスク一覧をそれぞれ表示し、タスクがすべてのworkerノードにデプロイされていることを確認してください。

4. コンフィグの一覧を表示してください。fluent_fluent.confが作成されていることを確認してください。

5. **いずれかのworkerノードで実施** Fluentdコンテナのログを表示してください。起動時に使用したfluent.confの内容が表示されます。修正したfluent.confの内容でFluentdが起動していることを確認してください。

なお、修正済のfluent.confを含めてイメージをビルドする手もあります。しかし、それだとfluent.confを修正するたびにイメージをビルドしなおし、composeファイルのタグを書き換える必要もありとても手間です。fluent.confのように後から設定を見直す可能性のある設定ファイルは本プラクティスでやっているようにconfigにした方が楽です。

## 4. テスト用アプリケーションのデプロイ

テスト用のアプリケーションをデプロイし、ログがFluentdで収集されCloudWatch Logsに保存されることを確認します。

1. 以下満たすcomposeファイル`log-test.yaml`を作成してください。（[ヒント①](https://docs.docker.com/compose/compose-file/compose-file-v3/#logging)、[ヒント②](https://docs.docker.com/config/containers/logging/fluentd/)、[ヒント③](https://docs.docker.com/config/containers/logging/log_tags/)）

- service: log-test
  - image: nginx
  - deploy: レプリカ2
  - ports: コンテナのtcp80をホストの8000ポートで公開
  - logging: ドライバでfluentdを指定。fluentdのアドレスは`127.0.0.1:24224`、ログのタグとして`docker.<コンテナ名>.<コンテナID>`を付与

2. 上記作成したcomposeファイルを指定し、スタック`test`を作成してください。

3. スタックの一覧、スタック内のサービス一覧、スタック内のタスク一覧をそれぞれ表示し、タスクが2つデプロイされていることを確認してください。

4. AWSのマネジメントコンソールに接続してください。CloudWatch Logsを表示し`docker-practice`ロググループが作成されていることを確認してください。（testをデプロイしてからログが格納されるまで少し時間がかかります。長くても1分くらいだと思います。）

5. `docker-practice`ロググループに`docker.<コンテナ名>.<コンテナID>`のログストリームが作成されていることを確認してください。また、ログストリームの中にログが書き込まれていることを確認してください。

6. スタック`test`を削除してください。しばらく(1分くらい)待ってからスタック`fluentd`を削除してください。

7. AWSに作成したロググループおよびログストリームも削除してください。

> スタック`test`を消してからしばらく待ったのはなぜですか？
> スタック`test`を消すときにコンテナのログが吐かれます。その時、Fluentdがないとログがバッファに溜まるようです。それで何か不具合が起こるとも思えませんが、一応ログを吐き切らせたからすべて削除するようにしたかったのです。

---

[TOP](../README.md)   
前: -  
次: [サービスのヘルスチェック](./swarm-service-healthcheck.md)  