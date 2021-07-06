[TOP](../README.md)   
前: [ネットワーク](./swarm-network.md)  
次: [シークレットの使用](./swarm-secret.md)  

---

# コンフィグの使用

コンテナ内部で使用する設定ファイルや環境変数は基本的にはコンテナイメージに含めて構成します。しかし、中にはコンテナイメージに含めたくない場合もあります。たとえば、開発/本番で同じコンテナイメージを使用したいが、接続先のドメインが環境によって異なる場合、環境差異になる部分だけコンテナイメージの外で設定できると便利です。（もちろん、開発用イメージ、本番用イメージとイメージごと分ける手もあります。）  

Configをつかうことで設定ファイルをコンテナから切り離すことができます。

1. 以下のコマンドで`index.html`を作成してください。

``` sh
echo config desuyo > index.html
```

2. 以下満たすcomposeファイル`config-file.yaml`を作成してください。（[ヒント①](https://docs.docker.com/compose/compose-file/compose-file-v3/#configs)、[ヒント②](https://docs.docker.com/compose/compose-file/compose-file-v3/#configs-configuration-reference)）

- service名: service
  - image: nginx
  - replicas: 1
  - configs: indexを/usr/share/nginx/html/index.htmlにマウント
  - port: ホストの8000をコンテナの80にマッピング
- config名: index
  - file: ./index.html

3. 上記作成したcomposeファイルを指定し、スタック`test`を作成してください。なお、スタックを作成するときはカレントディレクトリにindex.htmlがあることを確認してください。

4. スタックの一覧、スタック内のサービス一覧、スタック内のタスク一覧をそれぞれ表示し、タスクが1つデプロイされていることを確認してください。

5. コンフィグの一覧を表示してください。スタック`test`の`index`があることを確認してください。([ヒント](https://docs.docker.com/engine/reference/commandline/config_ls/))

6. 以下コマンドでコンテナにアクセスしてください。index.htmlの内容が表示されることを確認してください。

``` sh
curl 127.0.0.1:8000
```

なお、一度登録したconfigの内容は更新できないようです。configの内容を更新したい場合、新しくconfigを作成してコンテナの使用するconfigを切り替え、その後古いconfigを消すという手順になります。（[ネタ元](https://docs.docker.com/engine/swarm/configs/#example-rotate-a-config)）

7. 以下コマンドで`index.html`の内容を書き換えてください。

``` sh
echo config no naiyou wo kakikaetayo > index.html
```

8. composeファイル`config-file.yaml`を以下のように修正してください。変更箇所はハイライトします。

- service名: service
  - image: nginx
  - replicas: 1
  - configs: `index2`を/usr/share/nginx/html/index.htmlにマウント
  - port: ホストの8000をコンテナの80にマッピング
- config名: `index2` (indexに2を追加)
  - file: ./index.html

9. 上記作成したcomposeファイルを指定し、スタック`test`をアップデートしてください。なお、スタックを作成するときはカレントディレクトリにindex.htmlがあることを確認してください。

10. スタックの一覧、スタック内のサービス一覧、スタック内のタスク一覧をそれぞれ表示し、タスクが1つデプロイされていることを確認してください。

11. コンフィグの一覧を表示してください。スタック`test`の`index`と`index2`があることを確認してください。

12. 以下コマンドでコンテナにアクセスしてください。修正したindex.htmlの内容が表示されることを確認してください。

``` sh
curl 127.0.0.1:8000
```

13. コンフィグ`index`を手動で削除してください。([ヒント](https://docs.docker.com/engine/reference/commandline/config_rm/))

14. スタック`test`を削除してください。

このプラクティスの解答例は[こちら](./.ans/swarm-config.md)

---

[TOP](../README.md)   
前: [ネットワーク](./swarm-network.md)  
次: [シークレットの使用](./swarm-secret.md)  