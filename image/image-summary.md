[TOP](../README.md)   
前: [イメージの作成](./image-build.md)  
次: [イメージの手動運搬](./image-transport.md)  

---

# まとめ

ここまでの内容を振り返ります。

1. ``registry:2.7.1``のイメージを使いコンテナをバックグラウンドで実行してください。また、ホストOSの``5000``ポートをコンテナの``5000``ポートに繋いでください。

2. テストイメージをビルドするためのディレクトリを作成し移動してください。

3. 以下のコマンドでindex.htmlを作成してください。
   ``` sh
   echo "self build sita image de ugoitemasu" > index.html
   ```

4. 以下を満たすコンテナイメージをビルドしてください。ビルドするイメージ名は``{ホストOS名}:5000/httpd:selfbuild``としてください。（Dockerfileの記述は[日本語マニュアル](https://docs.docker.jp/engine/reference/builder.html#dockerfile)を参考にする）
   - ベースイメージは``alpine:latest``を使用
   - 以下のコマンドを実行しベースイメージにhttpdをインストール
     ``` sh
     apk update
     apk add apache2
     ```
   - index.htmlを``/var/www/localhost/htdocs/``にコピー
   - ``80``ポートを公開
   - コンテナ起動時の実行コマンドは以下
     ``` sh
     /usr/sbin/httpd -D FOREGROUND
     ```

5. ``{ホストOS名}:5000/httpd:selfbuild``イメージのコンテナをバックグラウンドで起動してください。また、ホストOSの``80``ポートをコンテナの``80``ポートに繋いでください。

6. ホストOSから``curl localhost:80``で接続してください。``self build sita image de ugoitemasu``が表示されることを確認してください。

7. ``{ホストOS名}:5000/httpd:selfbuild``をプライベートイメージレジストリにpushしてください。

ここからの手順はホストOSに接続可能なもう一台のサーバで作業してください。なお、もう一台のサーバからホストOSのホスト名が名前解決できるように設定しておいてください。

8. もう一台のサーバで``{ホストOS名}:5000/httpd:selfbuild``イメージのコンテナをバックグラウンドで起動してください。また、もう一台のサーバの``80``ポートをコンテナの``80``ポートに繋いでください。

9. もう一台のサーバから``curl localhost:80``で接続してください。``self build sita image de ugoitemasu``が表示されることを確認してください。

両方のサーバで実施してください。

10. 以下コマンドでコンテナをすべて削除してください。
    ``` sh
    docker rm -f `docker ps -a -q`
    ```

11. 以下コマンドでイメージを削除してください。
    ``` sh
    docker rmi {ホストOS名}:5000/httpd:selfbuild
    ```

12. ホストOSに作成したテストイメージビルド用のディレクトリを削除してください。

また、興味のある方は[イメージの手動運搬](./image-transport.md)も確認してください。

<details>
<summary>
答え(一例です)
</summary>

1. 以下コマンドを実行する。
```
docker run -d -p 5000:5000 registry:2.7.1
```

2. 以下コマンドを実行する。
```
$ mkdir {テストイメージをビルドするためのディレクトリ名}
$ cd {テストイメージをビルドするためのディレクトリ名}
```

3. プラクティスの指示コマンドを実行してください。
4. 以下一連コマンドを実行する。
```
$ cat <<EOF > Dockerfile
FROM alpine:latest
RUN apk update
RUN apk add apache2
COPY index.html /var/www/localhost/htdocs/
EXPOSE 80/tcp
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
EOF
$ hostname
{ホストOS名}
$ docker build -t {ホストOS名}:5000/httpd:selfbuild .
```

5. 以下コマンドを実行する。
```
docker run -d -p 80:80 {ホストOS名}:5000/httpd:selfbuild
```

6. プラクティスの指示コマンドを実行して確認してください。
```
$ curl localhost:80
"self build sita image de ugoitemasu"
```

7. 以下コマンドを実行する。
```
docker push {ホストOS名}:5000/httpd:selfbuild
```

8. 以下コマンドを実行する。
```
$ docker pull {ホストOS名}:5000/httpd:selfbuild
selfbuild: Pulling from httpd
9824c27679d3: Pull complete
aa1ebd0dde91: Pull complete
17782f8e77a5: Pull complete
11a7891f47af: Pull complete
Digest: sha256:d641eb700e20318ec56ee692ae059b73bb86008dcccf0a9bff8856f932388df0
Status: Downloaded newer image for ip-10-0-10-220.ap-southeast-2.compute.internal:5000/httpd:selfbuild
ip-10-0-10-220.ap-southeast-2.compute.internal:5000/httpd:selfbuild
$ docker run -d -p 80:80 {ホストOS名}:5000/httpd:selfbuild

なお、docker pull実行時に以下のようなエラー

「Error response from daemon: Get "https://ip-10-0-10-220.ap-southeast-2.compute.internal:5000/v2/": http: server gave HTTP response to HTTPS client」

が出た際は、docker pullを実行する別マシンより以下一連のコマンドを実行すると解決できる可能性があります。
$ sudo echo "{"insecure-registries": ["ip-10-0-10-220.ap-southeast-2.compute.internal:5000"]}" > /etc/docker/daemon.json
$ sudo systemctl restart docker
```

9. プラクティスの指示コマンドを実行して確認してください。
```
$ curl localhost:80
"self build sita image de ugoitemasu"
```

10. プラクティスの指示コマンドを実行してください。
11. プラクティスの指示コマンドを実行してください。
12. 以下コマンドを実行する。
```
$ cd ..
$ rm -rf {テストイメージをビルドするためのディレクトリ名}
```

</details>

---

[TOP](../README.md)   
前: [イメージの作成](./image-build.md)  
次: [イメージの手動運搬](./image-transport.md)  