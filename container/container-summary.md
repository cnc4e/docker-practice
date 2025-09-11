[TOP](../README.md)   
前: [コンテナのログ](./container-log.md)  
次: -  

---

# まとめ

ここまでの内容を振り返ります。

1. ホストOSに``~/container-mount``ディレクトリを作成し、以下内容の``index.html``を作成してください。
   ``` 
   docker run de iroiro sitei suruno taihen
   ```

2. 以下をすべて満たすコンテナを実行してください。
      - イメージは``nginx:1.19.2``
   - バックグラウンド実行
   - ホストOSの``~/container-mount``をコンテナの``/usr/share/nginx/html``にマウント
   - ホストOSの``8080``ポートとコンテナの``80``ポートを接続
   - ロギングドライバで``json-file``、ファイルサイズの上限を``10MB``、世代数を``3``
   - 環境変数に``ENV=docker-practice``を設定

3. コンテナが動いていることを確認してください。

4. ホストOSからlocalhost:8080に対してcurlを実行してください。``~/container-mount``配下に作成したindex.htmlの内容が表示されることを確認してください。

5. コンテナに``env``の追加コマンドを発行し環境変数``ENV=docker-practice``が設定されていることを確認してください。

6. 以下コマンドでコンテナのログ設定を確認してください。
   ``` sh
   docker inspect {コンテナID} | grep -e Type -e max-file -e max-size
   ```

7. 以下コマンドですべてのコンテナを削除してください。
    ``` sh
    docker rm -f `docker ps -a -q`
    ```

このように、コンテナ起動時に必要な設定を指定して起動します。今回紹介した以外にも``docker run``にはさまざまなオプションがあります。興味のある方は[こちら](https://docs.docker.jp/engine/reference/commandline/run.html)を確認ください。

しかし、毎回runのオプションでいろいろ設定するのは大変です。コンテナの数が増えるとさらに手間がかかります。これを解決するために``docker-compose``を使用します。docker-composeを使えばコンテナ起動のコマンドをファイルに記述し、何度でも同じ設定のコンテナを起動できます。（なお、プロダクション環境ではdocker-composeも使わず、KubernetesやECSなどのコンテナオーケストレーションを使うのが一般的です。）

<details>
<summary>
答え(一例です)
</summary>

1. 以下コマンドを実行する。
```
$ mkdir ~/container-mount
$ touch ~/container-mount/index.html
$ echo docker run de iroiro sitei suruno taihen > ~/container-mount/index.html
```

2. 


3. 以下コマンドを実行して確認してください。
```
$ docker ps
CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS         PORTS                                   NAMES
426281bae21c   nginx:1.19.2   "/docker-entrypoint.…"   9 seconds ago   Up 8 seconds   0.0.0.0:8080->80/tcp, :::8080->80/tcp   vigilant_bartik
```

4. 以下コマンドを実行して確認してください。
```
$ curl localhost:8080
docker run de iroiro sitei suruno taihen
```

5. 以下コマンドを実行して確認してください。
```
$ docker exec -it {docker psで確認したコンテナID} bash
# echo $ENV
docker-practice
```


</details>

---

[TOP](../README.md)   
前: [コンテナのログ](./container-log.md)  
次: -  
