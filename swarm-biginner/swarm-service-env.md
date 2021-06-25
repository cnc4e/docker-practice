[TOP](../README.md)   
前: [サービスのヘルスチェック](./swarm-service-healthcheck.md)  
次: -  

---

# サービスの環境変数

コンテナのベストプラクティスとして環境差異となるパラメータを環境変数で指定できるようにするというものがあります。アプリケーションをそういった作りにした後、サービスで起動するときに環境変数を指定します。指定の方法は`パラメータ指定`と`ファイル読み込み`の2通りあります。

`パラメータ指定`は環境変数を1つずつ設定するやり方です。

`ファイル読み込み`は外部のファイルに環境変数の設定を記述しておき取り込む方法です。複数のサービスで同じ環境変数を使う場合に役立ちます。

## パラメータ指定

1. 以下を満たすcomposeファイル`service-env-parameter.yaml`を作成してください。（[ヒント](https://docs.docker.com/compose/compose-file/compose-file-v3/#environment)）

- service名: test
- image: nginx
- replicas: 1　
- environment: 環境変数envにdevを設定

2. 上記作成したcomposeファイルを指定し、スタック`test`を作成してください。

3. スタックの一覧、スタック内のサービス一覧、スタック内のタスク一覧をそれぞれ表示し、タスクが1つデプロイされていることを確認してください。また、タスクがスケジュールされたノード名も確認してください。

4. **タスクがスケジュールされたワーカー**にてスタック`test`でデプロイされたコンテナに追加コマンドを発行し、環境変数の設定を表示してください。`env=dev`が設定されていることを確認してください。

5. スタック`test`を削除してください。

## ファイル読み込み

1. 以下コマンドでファイル`common.env`を作成してください。

``` sh
cat <<EOF > common.env
parameter=common
env=dev
EOF
```

2. 以下を満たすcomposeファイル`service-env-file.yaml`を作成してください。（[ヒント](https://docs.docker.com/compose/compose-file/compose-file-v3/#env_file)）

- service名: nginx
  - image: nginx
  - replicas: 2
  - env_file: common.envを読み込み
- service名: httpd
  - image: httpd
  - replicas: 2　
  - env_file: common.envを読み込み

3. 上記作成したcomposeファイルを指定し、スタック`test`を作成してください。

4. スタックの一覧、スタック内のサービス一覧、スタック内のタスク一覧をそれぞれ表示し、タスクが2つずつデプロイされていることを確認してください。

5. **いずれかのワーカー**にてスタック`test`でデプロイされたコンテナに追加コマンドを発行し、環境変数の設定を表示してください。両方のコンテナに`parameter=common`と`env=dev`が設定されていることを確認してください。

6. スタック`test`を削除してください。

---

[TOP](../README.md)   
前: [サービスのヘルスチェック](./swarm-service-healthcheck.md)  
次: -  