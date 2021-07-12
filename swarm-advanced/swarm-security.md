[TOP](../README.md)   
前: [監視](./swarm-metrics.md)  
次: [バックアップ](./swarm-backup.md)  

---

# セキュリティ

コンテナにおいてもセキュリティは重要です。セキュリティに対策についていくつか記載します。

## 1.　overlayネットワークの暗号化

overlayネットワークはホスト間に跨る通信です。overlayネットワークはデフォルトでは暗号化されませんが暗号化を有効にすることもできます。（暗号化するとネットワークのパフォーマンスに影響があります。いきなり本番で使用する前にパフォーマンスの問題がないか確認しましょう。）

なお、overlayネットワークを暗号化するにはノード間でESP(ip protocol:50)の通信を許可する必要があるのであらかじめ設定しておいてください。（TCP/UDPの50番ではないので注意！）　[ネタ元](https://docs.docker.com/engine/swarm/swarm-tutorial/#open-protocols-and-ports-between-the-hosts)

1. 以下満たすcomposeファイル`overlay-encrypted.yaml`を作成してください。

- service名: nginx
  - image: nginx
  - deploy mode: replicated
  - replicas: 1
  - networks: encrypted
- service名: httpd
  - image: httpd
  - deploy mode: replicated
  - replicas: 1
  - networks: encrypted
- network名: encrypted
  - driver: overlay
  - driverオプション: `encrypted: ""`を指定

2. 上記作成したcomposeファイルを指定し、スタック`test`を作成してください。

3. スタックの一覧、スタック内のサービス一覧、スタック内のタスク一覧をそれぞれ表示し、タスクが2つデプロイされていることを確認してください。また、nginxのタスクがスケジュールされたノードを確認しておいてください。（後で接続します。）

4. ネットワークの一覧を表示し、`test_encrypted`という名前のoverlayネットワークがあることを確認してください。

5. ネットワーク`test_encrypted`の詳細情報を表示してください。オプションに`encrypted: ""`が設定されていることを確認してください。（IPAMのオプションではないので注意）

6. **nginxが動いているノード** に接続しnginxのコンテナからservice名を指定してhttpdにcurlしてください。問題なく通信できることを確認してください。

7. スタック`test`を削除してください。

## 2. イメージの脆弱性診断

コンテナイメージそのものに脆弱性が潜んでいる可能性があります。そのようなイメージを使うと攻撃される恐れがあるため脆弱性のない安全なイメージを使用しましょう。イメージに脆弱性が含まれているかは診断ツールを使って確認します。有名なもので[trivy](https://github.com/aquasecurity/trivy)というOSSのツールがあります。

本プラクティスではdocker hubで公開されているオフィシャルのhttpdイメージを使用します。[こちら](https://hub.docker.com/_/httpd)です。オフィシャルのイメージはベースイメージとして信頼できるものです。Dockerとしてもオフィシャルイメージの利用を推奨しています。（[ネタ元](https://docs.docker.com/docker-hub/official_images/)）　ですが、オフィシャルイメージが完全に安全というわけではありません。

1. 以下コマンドで`httpd:2.4.47`の脆弱性を確認してください。

``` sh
docker run --rm aquasec/trivy httpd:2.4.47
```

2. 以下コマンドで`httpd:2.4.72-alpine`の脆弱性を確認してください。`httpd:2.4.47`と比較して明らかに脆弱性が少ないはずです。

``` sh
docker run --rm aquasec/trivy httpd:2.4.47-alpine
```

このようにイメージの脆弱性診断ツールを使用して脆弱性を確認できます。ベースイメージには脆弱性の少ないものを採用することでリスクを低減できます。また、自分たちでビルドしたイメージについても脆弱性を確認しましょう。すべての脆弱性に自分達で対応するのはとても大変ですが、最低限CRITICALやHIGHなど危険性の高いものは対応した方がよいでしょう。

また、このような脆弱性診断をコンテナレジストリに任せることもできます。たとえばAWSのコンテナレジストリサービスである[ECR](https://aws.amazon.com/jp/ecr/)はイメージプッシュ時に自動でスキャンを実行してくれます。

## 3. セキュリティ診断

Docker環境のセキュリティベストプラクティスをまとめたものとして[CIS Docker Benchmark](https://www.cisecurity.org/benchmark/docker/)というものがります。リンクのサイトから無料で文章をダウンロードできます。（要登録）　また、この文章への対応状況を自動でチェックする[docker-bench-security](https://github.com/docker/docker-bench-security)と言うツールをDockerが公開しています。このツールを使い、Docker環境の安全性を確認できます。

1. 以下コマンドでdocker-bench-securityを実行してください。

``` sh
docker run --rm --net host --pid host --userns host --cap-add audit_control \
    -e DOCKER_CONTENT_TRUST=$DOCKER_CONTENT_TRUST \
    -v /etc:/etc:ro \
    -v /usr/bin/containerd:/usr/bin/containerd:ro \
    -v /usr/bin/runc:/usr/bin/runc:ro \
    -v /usr/lib/systemd:/usr/lib/systemd:ro \
    -v /var/lib:/var/lib:ro \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    --label docker_bench_security \
    docker/docker-bench-security
```

実行すると各指標に対しての結果が表示されます。`[WARN]`の箇所は対応した方が良い指標になります。たとえば私の環境では以下のWARNが出力されました。

【出力例】

```
...
[WARN] 1.5  - Ensure auditing is configured for the Docker daemon
[WARN] 1.6  - Ensure auditing is configured for Docker files and directories - /var/lib/docker
[WARN] 1.7  - Ensure auditing is configured for Docker files and directories - /etc/docker
[WARN] 1.8  - Ensure auditing is configured for Docker files and directories - docker.service
[WARN] 1.9  - Ensure auditing is configured for Docker files and directories - docker.socket
...
```

2. 上記WARNへ自力で対処してみましょう。各指標に対しての解決策はDocker Benchmarkの文章の中にヒントが書かれているのでそれらを参考にします。（解答例に私の環境で対処した時のやり方を書いておきます。）

3. docker-bench-securityを再度実行してWARNだった指標がPASSになったことを確認してください。

【出力例】

```
[PASS] 1.5  - Ensure auditing is configured for the Docker daemon
[PASS] 1.6  - Ensure auditing is configured for Docker files and directories - /var/lib/docker
[PASS] 1.7  - Ensure auditing is configured for Docker files and directories - /etc/docker
[PASS] 1.8  - Ensure auditing is configured for Docker files and directories - docker.service
[PASS] 1.9  - Ensure auditing is configured for Docker files and directories - docker.socket
```

なお、上記のようにホストに対する対応は1台だけでなくすべてのノードに対して実行する必要があります。docker-bench-securityはすべてのノードで確認するようにしましょう。

## 4.　その他tips

以下、本プラクティスではとくに課題を用意していませんが一般的なセキュリティ関連のtipsを以下に記載します。

- ホストに余計なソフトはインストールしない
- ホストのOSグループ`docker`に一般ユーザを所属させない
- ベースイメージは信頼できる提供元のものを使う
- イメージには必要最小限のものしか入れない
- コンテナ実行ユーザはroot以外を使用する
- shやbashなどのコマンドはコンテナから削除する
- 特権コンテナは安易に作らない
- パスワードなどのシークレット情報はコンテナイメージ、composeファイルに埋め込まない
- docker apiを外部に公開するときはTLSやSSHで保護する

また、コンテナ環境のセキュリティ指針として有名なもので米国国立標準技術研究所（NIST）という団体が公開したSP800-190という文章があります。それを日本語訳したものが日本の情報処理推進機構（IPA）により公開されています。[こちら](https://www.ipa.go.jp/files/000085279.pdf)です。ともて興味深い内容ですので本番環境でコンテナを運用する前には是非読んでみるよ良いでしょう。

*[解答例](./.ans/swarm-security.md)*

---

[TOP](../README.md)   
前: [監視](./swarm-metrics.md)  
次: [バックアップ](./swarm-backup.md)  
