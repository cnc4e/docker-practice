[TOP](../README.md)   
前: [docker-composeによる複数コンテナの連携](./compose-multi.md)  
次: -  

---

# まとめ

ここまでの内容を振り返ります。

1. ``compose-summary``ディレクトリを作成し移動してください。

2. ``index.html``を作成してください。内容は何でも良いです。

3. 以下を満たす``docker-compose.yml``を作成してください。（composeファイルの書き方は[日本語マニュアル](https://docs.docker.jp/compose/compose-file.html#)を参考にする）
   - version: 3
   - ``test``という名前のネットワークを作成
     - ドライバは``bridge``
   - ``client``という名前のサービスを作成
     - イメージは``nginx:1.19.2``
     - ログドライバは``journald``
     - 環境変数``TARGET``に``server``を設定
     - ネットワーク``test``に所属
   - ``server``という名前のサービスを作成
     - イメージは``nginx:1.19.2``
     - ログドライバは``journald``
     - ホストの``8080``をコンテナの``80``に接続 
     - ホストの``./index.html``をコンテナの``/usr/share/nginx/html/index.html``にマウント
     - ネットワーク``test``に所属

4. 上記``docker-compose.yml``を使いコンテナをバックグランドで起動してください。

5. コンテナが動いていることを確認してください。

6. サービス``client``のコンテナにログインし環境変数の設定を確認してください。

7. サービス``client``のコンテナから以下のコマンドを実行し作成したindex.htmlの内容が表示されることを確認してください。
   ``` sh
   curl -s $TARGET
   ```

8. ホストOSから以下のコマンドを実行し作成したindex.htmlの内容が表示されることを確認してください。
   ``` sh
   curl -s localhost:8080
   ```

9. 以下コマンドでjournalにコンテナのログが出力されていることを確認してください。
   ``` sh
   journalctl -xe
   ```

10. dokcer-composeでコンテナを削除してください。

11. ``compose-summary``ディレクトリを削除してください。

<details>
<summary>
答え(一例です)
</summary>

1. 以下コマンドを実行する。
```
mkdir compose-summary
cd compose-summary
```

2. 以下コマンドを実行する。
```
echo "{任意の文章}" > index.html
```

3. 以下コマンドを実行する。
```
cat <<EOF > docker-compose.yml
version: '3'
services:
  client:
    image: nginx:1.19.2
    logging:
      driver: journald
    environment:
      TARGET: server
    networks:
      - test
  server:
    image: nginx:1.19.2
    logging:
      driver: journald
    ports:
      - "8080:80"
    volumes:
      - ./index.html:/usr/share/nginx/html/index.html
    networks:
      - test
networks:
  test:
    driver: bridge
EOF
```

4. 以下コマンドを実行する。
```
docker-compose up -d
```

5. 以下コマンドを実行して確認してください。
```
$ docker ps
CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS         PORTS                                   NAMES
966bb4a571de   nginx:1.19.2   "/docker-entrypoint.…"   9 seconds ago   Up 8 seconds   0.0.0.0:8080->80/tcp, :::8080->80/tcp   compose-summary-server-1
9332ea644543   nginx:1.19.2   "/docker-entrypoint.…"   9 seconds ago   Up 8 seconds   80/tcp                                  compose-summary-client-1
```

6. 以下一連のコマンドを実行して確認してください。
```
$ docker-compose exec client sh
WARN[0000] /home/ssm-user/docker-practice/compose-summary/docker-compose.yml: the attribute `version` is obsolete, it will be ignored, please remove it to avoid potential confusion 

# env | grep TARGET
TARGET=server
```

7. 以下一連のコマンドを実行して確認してください。
```
$ docker-compose exec client sh
WARN[0000] /home/ssm-user/docker-practice/compose-summary/docker-compose.yml: the attribute `version` is obsolete, it will be ignored, please remove it to avoid potential confusion 

# curl -s $TARGET
{任意の文章}

なお5.のコマンドを実行直後の場合は、はじめの $ docker-compose exec client sh を実行する必要はありません
```

8. プラクティスの指示コマンドを実行して確認してください。
```
$ curl -s localhost:8080
nandemo ii

なお、7.のコマンドを実行直後の場合は、 exit コマンドでコンテナから出てください。
```

9. プラクティスの指示コマンドを実行して確認してください。
```
$ journalctl -xe
░░ Defined-By: systemd
░░ Support: https://lists.freedesktop.org/mailman/listinfo/systemd-devel
░░ 
░░ A start job for unit UNIT has begun execution.
░░ 
░░ The job identifier is 25.
Sep 30 00:35:08 ip-10-0-10-220.ap-southeast-2.compute.internal systemd[3760]: Finished systemd-tmpfiles-clean.service - C>
░░ Subject: A start job for unit UNIT has finished successfully
░░ Defined-By: systemd
░░ Support: https://lists.freedesktop.org/mailman/listinfo/systemd-devel
░░ 
░░ A start job for unit UNIT has finished successfully.
░░ 
░░ The job identifier is 25.
lines 151-165/165 (END)
```

10. 以下コマンドを実行する。
```
docker-compose down
```

11. 以下コマンドを実行する。
```
rm -rf compose-summary
```

</details>

---

[TOP](../README.md)   
前: [docker-composeによる複数コンテナの連携](./compose-multi.md)  
次: -  
