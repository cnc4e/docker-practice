[TOP](../README.md)   
前: [コンテナにファイルシステムをマウント](./container-volume.md)  
次: [コンテナのログ](./container-log.md)  

---

# コンテナに環境変数を設定

コンテナはコンテナイメージから起動します。同じイメージで起動したコンテナは基本的に同じものが動きます。しかし、たとえば開発環境と本番環境などでドメイン名が違う、接続するDBのホスト名が違うなどパラメータを変えて起動したいことがあります。この様な場合はコンテナに環境変数を指定して起動します。

1. ``centos:8``のイメージを使いコンテナをバックグラウンドで実行してください。なお、centosのイメージはコマンドを指定しないとすぐに停止するので``sh -c "sleep 3600"``などのコマンドを指定して実行してください。

2. 作成したコンテナに設定されている環境変数を表示し、``ENV``というkeyの環境変数がないことを確認してください。

3. コンテナを削除してください。

4. ``centos:8``のイメージを使いコンテナをバックグラウンドで実行してください。この時、環境変数に``ENV=dev``を設定してください。環境変数の指定は``docker runコマンドのオプション``で指定します。やり方は[日本語マニュアル](http://docs.docker.jp/engine/reference/commandline/run.html#e-env-env-file)を参考にしてください。

5. 作成したコンテナに設定されている環境変数を表示し、``ENV=dev``が設定されていることを確認してください。

6. 以下コマンドでコンテナをすべて削除してください。
   ``` sh
   docker rm -f `docker ps -a -q`
   ```

このように、コンテナ起動時に環境変数を指定し環境差異を表現できます。しかし、これは``環境変数で後からパラメータを指定できる様にアプリケーションが開発されている``という前提です。コンテナでアプリケーション動かす際はこの点についてとくに注意して開発してください。（環境変数でなくても設定ファイルをコンテナ外に保存し、起動時に設定ファイルをマウントさせるということもできますが、環境変数で指定できた方が楽です。）

<details>
<summary>
答え(一例です)
</summary>

1. 以下コマンドを実行する。
```
docker run -d centos:8 sh -c "sleep 3600"
```

2. 以下コマンドを実行する。
```
$ docker ps
CONTAINER ID   IMAGE      COMMAND                CREATED              STATUS              PORTS     NAMES
d13ffff63bad   centos:8   "sh -c 'sleep 3600'"   About a minute ago   Up About a minute             laughing_newton
$ docker exec -it {docker psで確認したコンテナID} bash
# echo $ENV

#
```

3. 以下コマンドを実行する。
```
# exit
exit
$ docker rm -f {docker psで確認したコンテナID}
{docker psで確認したコンテナID}
```

4. 

</details>

---

[TOP](../README.md)   
前: [コンテナにファイルシステムをマウント](./container-volume.md)  
次: [コンテナのログ](./container-log.md)  
