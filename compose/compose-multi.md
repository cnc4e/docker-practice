[TOP](../README.md)  
前: [docker-composeによるネットワーク作成](./compose-network.md)  
次: [まとめ](./compose-summary.md)  

---

# docker-composeによる複数コンテナの連携

コンテナのベストプラクティスとして接続先の指定はIPアドレスではなく、ホスト名などの名前でアクセスするというのがあります。dockerでこのベストプラクティスを実践するにはdocker-composeでコンテナを同じネットワークに所属させればよいです。同じネットワーク内に属するコンテナはサービス名で通信できます。

1. ``multi-container``ディレクトリを作成し移動してください。

2. 以下を満たす``docker-compose.yml``を作成してください。（ヒント：composeのlingsは[日本語マニュアル](https://docs.docker.jp/compose/compose-file.html#links)を参考にする。）
   - composeのバージョンは``3``
   - ネットワーク定義
     - ネットワーク名: ``test``
       - driver: ``bridge``
   - サービス定義
     - サービス名： ``first``
       - image: ``nginx:1.19.2``
       - ネットワーク``test``に所属
     - サービス名： ``second``
       - image: ``nginx:1.19.2``
       - ネットワーク``test``に所属
     - サービス名： ``third``
       - image: ``nginx:1.19.2``
       - （ネットワークの所属はとくに指定しない！）

3. 上記作成した``docker-compose.yml``を使い、コンテナをバックグランドで実行してください。

4. コンテナが動いていることを確認してください。

5. ``first``のコンテナから``second``のコンテナにサービス名でcurlしてください。``接続できること``を確認してください。

6. ``first``のコンテナから``third``のコンテナにサービス名でcurlしてください。``接続できない``を確認してください。

7. docker-composeで起動したコンテナをすべて削除してください。

8. `multi-container`ディレクトリを削除してください。

このように、同じネットワークであればサービス名でアクセスできます。コンテナ内部の設定はあらかじめサービス名で通信するように設定しておけばコンテナを何度再作成してもIPアドレスを気にする必要はありません。

<details>
<summary>
答え(一例です)
</summary>

1. 以下コマンドを実行する。
```
$ mkdir multi-container
$ cd multi-container
```

2. 以下コマンドを実行する。
```
cat <<EOF > docker-compose.yml
version: '3'
services:
  first:
    image: nginx:1.19.2
    networks:
      - test
  second:
    image: nginx:1.19.2
    networks:
      - test
  third:
    image: nginx:1.19.2
networks:
  test:
    driver: bridge
EOF
```

3. 以下コマンドを実行する。
```
docker-compose up -d
```

4. 以下コマンドを実行して確認してください。
```
$ docker ps
CONTAINER ID   IMAGE          COMMAND                  CREATED              STATUS              PORTS     NAMES
d2ad2a7fc781   nginx:1.19.2   "/docker-entrypoint.…"   About a minute ago   Up About a minute   80/tcp    multi-container-third-1
1616109d3c1b   nginx:1.19.2   "/docker-entrypoint.…"   About a minute ago   Up About a minute   80/tcp    multi-container-second-1
25018fad344f   nginx:1.19.2   "/docker-entrypoint.…"   About a minute ago   Up About a minute   80/tcp    multi-container-first-1
```

5. 以下一連のコマンドを実行する。
```
$ docker-compose exec first sh
WARN[0000] /home/ssm-user/docker-practice/multi-container/docker-compose.yml: the attribute `version` is obsolete, it will be ignored, please remove it to avoid potential confusion 

# curl second
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

6. 以下一連のコマンドを実行する。
```
$ docker-compose exec first sh
WARN[0000] /home/ssm-user/docker-practice/multi-container/docker-compose.yml: the attribute `version` is obsolete, it will be ignored, please remove it to avoid potential confusion

# curl third
curl: (6) Could not resolve host: third

なお5.のコマンドを実行直後の場合は、はじめの $ docker-compose exec first sh を実行する必要はありません
```

7. 以下コマンドを実行する。
```
docker-compose down

なお6.のコマンドを実行直後の場合は、 # exit でコンテナから出てください
```

8. 以下コマンドを実行する。
```
rm -rf multi-container
```

</details>

---

[TOP](../README.md)  
前: [docker-composeによるネットワーク作成](./compose-network.md)  
次: [まとめ](./compose-summary.md)  
