[TOP](../README.md)  
前: -  
次: [docker-composeによるネットワーク作成](./compose-network.md)  

---
# docker-composeコマンドの注意
docker composeにはv1とv2があります。v1とv2では実行コマンドが異なり、v1は`docker-compose`で、v2は`docker compose`と、ハイフンを入れるかどうかの違いがあります。これらの動作に大きな違いはありませんが、互換性がないため、v2を入れた状態で`docker-compose`を実行してもエラーとなります。本演習では`docker-compose`を使うようにしていますので、自身の環境に応じて`docker compose`にて実行するようにしてください。

# docker-composeによるコンテナ起動

docker-composeはコンテナ起動の設定をファイルに定義し、定義した内容のコンテナを簡単に起動・削除できるツールです。開発中などで何度もコンテナを上げ直したい時に重宝します。docker runよりもdocker-composeでコンテナを起動することの方が多いかもしれません。

1. 以下コマンドで``docker-compose.yml``ファイルを作成してください。（composeファイルの内容については[日本語マニュアル](http://docs.docker.jp/compose/compose-file.html)と見比べてみてください。）
   ``` sh
   cat <<EOF > docker-compose.yml
   version: '3'
   services:
     web:
       image: nginx:1.19.2
       ports:
         - 8080:80
       logging:
         driver: "json-file"
         options:
           max-size: "10m"
           max-file: "2"
       environment:
         ENV: test
   EOF
   ```

2. 上記``docker-compose.yml``を使用してコンテナをバックグランドで実行してください。（ヒント：composeで起動するのは[docker-compose up](http://docs.docker.jp/compose/reference/up.html)コマンドを使います。）

3. コンテナが動いていることを確認してください。
   
4. ホストOSからlocalhost:8080に対してcurlを実行してください。
   
5. コンテナに``env``の追加コマンドを発行し環境変数``ENV=test``が設定されていることを確認してください。docker-composeで起動したコンテナに対する追加コマンドは以下のように[docker-compose exec](https://matsuand.github.io/docs.docker.jp.onthefly/compose/reference/exec/)コマンドを使うと便利です。
   ``` sh
   sudo docker-compose exec web env | grep ENV
   ```

6. 以下コマンドでコンテナのログ設定を確認してください。
   ``` sh
   docker inspect {コンテナID} | grep -e Type -e max-file -e max-size
   ```

7. docker-composeで起動したコンテナを削除してください。（ヒント：削除は[docker-compose down](http://docs.docker.jp/compose/reference/down.html)コマンドを使います。）

このようにdocker-composeを使うとdocker runで指定していた起動設定をいちいち指定しなくて済みます。また、composeで起動したコンテナは``<プロジェクト名>_<サービス名>_<連番>``という名前になります。プロジェクト名は``-p``オプションで指定できます。指定がない場合はカレントディレクトリ名がプロジェクト名になります。コンテナと一緒にネットワークも作られます。これにいては[docker-composeによるネットワーク作成](./compose-network.md)で触れます。

もう少しdocker-composeの練習します。

8. ホストOSに``~/compose-mount``というテスト用のディレクトリを作成してください。

9. 以下コマンドで``~/compose-mount``配下に``index.html``を作成してください。
   ```
   echo "compose de mount simasita" > ~/compose-mount/index.html
   ```

10. さらに以下を満たすように``docker-compose.yml``を修正してください。
    - ホストOSの``~/compose-mout``をコンテナの``/usr/share/nginx/html``にマウント（ヒント：[volume](http://docs.docker.jp/compose/compose-file.html#volumes-volume-driver)を使います。）

11. docker-composeでコンテナをバックグランドで起動してください。

12. ホストOSからlocalhost:8080に対してcurlを実行してください。``compose de mount simasita``と表示れるはずです。

13. docker-composeでコンテナを削除してください。

14. `~/compose-mount`を削除してください。

15. `docker-compose.yml`を削除してください。

<details>
<summary>
答え(一例です)
</summary>
docker compose


1. プラクティスの指示コマンドを実行してください。
2. 以下コマンドを実行する。
```
docker-compose up -d
```

3. 以下コマンドを実行して確認してください。
```
$ docker ps
CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS         PORTS                                   NAMES
6a6bcd7a538a   nginx:1.19.2   "/docker-entrypoint.…"   6 minutes ago   Up 6 minutes   0.0.0.0:8080->80/tcp, :::8080->80/tcp   docker-practice-web-1
```

4. 以下コマンドを実行する。
```
curl localhost:8080
```

5. プラクティスの指示コマンドを実行して確認してください。
6. プラクティスの指示コマンドを実行して確認してください。
7. 以下コマンドを実行する。
```
docker-compose down
```

8. 以下コマンドを実行する。
```
mkdir ~/compose-mount
```

9. 以下コマンドを実行した後、プラクティスの指示コマンドを実行してください。
```
cd ~/compose-mount
```

10. 以下のように`docker-compose.yml`を修正してください。
```
version: '3'
services:
  web:
    image: nginx:1.19.2
    ports:
      - 8080:80
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "2"
    environment:
      ENV: test
    volumes:  #追加
      - ~/compose-mount:/usr/share/nginx/html #追加
```

11. 2.と同じコマンドを実行する。
12. 4.と同じコマンドを実行して確認してください。
13. 7.と同じコマンドを実行する。
14. 以下コマンドを実行する。
```
rm -rf ~/compose-mount
```

15. 以下コマンドを実行する。
```
rm docker-compose.yml
```

</details>

---

[TOP](../README.md)  
前: -  
次: [docker-composeによるネットワーク作成](./compose-network.md)  
