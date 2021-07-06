[TOP](../README.md)   
前: [コンフィグの使用](./swarm-config.md)  
次: [ボリューム](./swarm-valume.md)  

---

# シークレットの使用

シークレットはコンフィグと同じ使い方ができるものです。シークレットはマネージャ内に情報を保存するときに暗号化されます。コンフィグは格納時に暗号化されません。（いずれにしてもswarmの情報を格納するRaftログは暗号化されているため、シークレットは二重に暗号化されるものと理解すれば良い？）　また、コンフィグはコンテナでマウントしなくても中身のデータを確認できますが、シークレットは中身の確認もできません。

シークレットはパスワードや証明書など機密情報をあつかうのにコンフィグよりも適しています。

1. 以下コマンドでファイルを作成してください。

``` sh
echo koreha config no data desu > config
echo koreha secret no data desu > secret
```

2. 以下満たすcomposeファイル`secret-file.yaml`を作成してください。（[ヒント](https://docs.docker.com/compose/compose-file/compose-file-v3/#secrets)）

- service名: service
  - image: nginx
  - replicas: 1
  - secrets: test-secretをマウント(path指定なし)
  - configs: test-configをマウント(path指定なし)
- secret名: test-secret
  - file: ./secret
- config名: test-config
  - file: ./config

3. 上記作成したcomposeファイルを指定し、スタック`test`を作成してください。なお、スタックを作成するときはカレントディレクトリにconfigおよびsecretがあることを確認してください。

4. スタックの一覧、スタック内のサービス一覧、スタック内のタスク一覧をそれぞれ表示し、タスクが1つデプロイされていることを確認してください。また、タスクを実行しているノードも確認しておいてください。

5. シークレット、コンフィグの一覧を表示してください。スタック`test`の`secret`および`config`があることを確認してください。（[ヒント](https://docs.docker.com/engine/reference/commandline/secret_ls/)）

6. シークレット、コンフィグの詳細を表示してください。シークレットはDataが表示されず、コンフィグはDataが表示されることを確認してください。コンフィグのDataに表示される情報を以下のようにbase64デコードしてください。configの内容が表示されるはずです。

``` sh
echo a29yZWhhIGNvbmZpZyBubyBkYXRhIGRlc3UK | base64 -d
```

7. **タスクを実行しているワーカー**にログインし、以下のコマンドを実行してください。コンフィグ、シークレットの内容が見えることを確認してください。

``` sh
docker exec <container id> ls /run/secrets/test-secret
docker exec <container id> cat /run/secrets/test-secret
docker exec <container id> ls /test-config
docker exec <container id> cat /test-config
```

8. スタック`test`を削除してください。

Secretを作成するときの元データには注意が必要です。たとえば上記手順だと`secret`というファイルに機密情報を記載しています。Docker内に保存されれば暗号化されますが、Secretを作成するときの元データはそのまま残ります。

*[解答例](./.ans/swarm-secret.md)*

---

[TOP](../README.md)   
前: [コンフィグの使用](./swarm-config.md)  
次: [ボリューム](./swarm-valume.md)  