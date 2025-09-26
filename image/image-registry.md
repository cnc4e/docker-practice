[TOP](../README.md)   
前: [イメージの取得/削除](./image-operation.md)  
次: [イメージの作成](./image-build.md)  

---

# イメージレジストリ

コンテナイメージを保管・共有するイメージレジストリはいくつかあります。大きく、パブリックとプライベートに分けられます。パブリックのイメージレジストリとしてはDocker公式の[Docker Hub](https://hub.docker.com/)が有名です。プライベートのイメージレジストリはさらにマネージド・サービスとスクラッチを選択できます。マネージド・サービスとしてはAWSの[ECR](https://aws.amazon.com/jp/ecr/)、Azureの[ACR](https://azure.microsoft.com/ja-jp/services/container-registry/)などがあります。スクラッチは自分でローカル環境に構築するレジストリで[Dockerレジストリ](http://docs.docker.jp/registry/index.html)が有名です。

以下の手順ではプライベートレジストリとして``Dockerレジストリ``を動かします。Dockerレジストリ自体もコンテナイメージで提供されているため、コンテナを実行すればすぐに使うことができます。

1. ``registry:2.7.1``のイメージを使いコンテナをバックグラウンドで実行してください。また、ホストOSの``5000``ポートをコンテナの``5000``ポートに繋いでください。

以上でホストOS上にプライベートなイメージレジストリができます。なお、レジストリのイメージデータは永続化が必要です。そのため、もしDockerレジストリを使う場合は``/var/lib/registry``をボリュームマウントなどで永続化しましょう。また、AWSやAzueeなどのクラウド環境ではマネージド・サービスを利用した方が良いでしょう。

次に、プライベートなイメージレジストリにイメージを保存してみます。

2. ホストOS内にダウンロード済みのコンテナイメージを確認してください。

3. 適当なコンテナイメージ1つを選択し、``{ホストOSのホスト名}:5000/testimage:v1``というイメージ名にタグをつけ直してください。（ヒント：イメージ名の操作は[docker tag](https://docs.docker.jp/engine/reference/commandline/tag.html)コマンドを使います。）

4. ホストOS内にダウンロード済みのコンテナイメージを確認してください。REPOSITORY:``{ホストOSのホスト名}:5000/testimage``、TAG:``v1``のイメージがあることを確認してください。

なお、イメージレジストリにイメージを保存（push）する前にレジストリへログインするか、レジストリを安全なレジストリとして登録します。今回はプライベートのレジストリであるため、安全なレジストリとして登録します。

5. 以下のように``/etc/docker/daemon.json``を作成します。（権限で書き込めない場合はviなどで作成してください。）
   ``` sh
   echo {"insecure-registries": ["{ホストOSのホスト名}:5000"]} > /etc/docker/daemon.json
   ```

6. dockerを再起動します。
   ``` sh
   sudo systemctl restart docker
   ```

これでホストOS上のレジストリを安全なレジストリとして登録できます。あとはpushすればレジストリにイメージが保存されます。なお、daemonの設定は安全なレジストリの追加以外にもさまざまな設定項目があります。設定できる内容については次の[日本語マニュアル](http://docs.docker.jp/engine/reference/commandline/daemon.html)をご確認ください。

7. イメージ``{ホストOSのホスト名}:5000/testimage:v1``をイメージレジストリに保存してください。（ヒント：イメージのリモートへの保存は[docker push](https://docs.docker.jp/engine/reference/commandline/push.html)コマンドを使います。）

8. プライベートレジストリにイメージが格納できたか確認します。以下のcurlコマンドをホストOSで実行してください。``testimage``が表示されるはずです。
   ``` sh
   curl localhost:5000/v2/_catalog
   ```

このようにイメージをイメージレジストリに格納できます。気づいたと思いますが、イメージ名には格納するレジストリ名を含めます。レジストリ名を名前解決可能なホスト名にすれば、ホストOS外からもプライベートレジストリに対してpush/pullできます。

9. dockerがインストール済みでホストOSに接続可能な別マシンから以下コマンド実行してください。
   ``` sh
   docker pull {ホストOSのホスト名}:5000/testimage:v1
   ```
10. 別マシンのローカルにあるイメージの一覧を表示してください。``{ホストOSのホスト名}:5000/testimage:v1``があることを確認してください。

11. 以下コマンドでホストOSのコンテナを削除してください。
    ``` sh
    docker rm -f `docker ps -a -q`
    ```

イメージレジストリがあるとイメージの共有が簡単に行えます。今回はプライベートなレジストリを使用しましたがDocker Hubなどでも同様にイメージを管理できます。ただし、認証が有効化されいてるレジストリに対しては``docker login``による認証が必要な場合もあるためレジストリの仕様を確認ください。

また、イメージレジストリがなくともイメージを手で配布することもできなくはないです。やり方は[イメージの手動運搬](./image-transport.md)で解説していますので興味のある方は見てください。

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
$ docker images
REPOSITORY                                                   TAG               IMAGE ID       CREATED        SIZE
nginx                                                        reproducibility   c57f52790069   3 days ago     133MB
hashicorp/terraform-mcp-server                               latest            5dbf8d6350f2   4 weeks ago    10.8MB
456247443832.dkr.ecr.ap-southeast-2.amazonaws.com/backend    latest            1cf72cc0df22   2 months ago   1.1GB
backend                                                      v2                1cf72cc0df22   2 months ago   1.1GB
456247443832.dkr.ecr.ap-southeast-2.amazonaws.com/frontend   latest            9ca1b9de7c3d   2 months ago   53MB
frontend                                                     v2                9ca1b9de7c3d   2 months ago   53MB
backend                                                      v1                b82d8430c71a   2 months ago   1.1GB
456247443832.dkr.ecr.ap-southeast-2.amazonaws.com/backend    <none>            b82d8430c71a   2 months ago   1.1GB
frontend                                                     v1                1df1a99e23e4   2 months ago   53MB
456247443832.dkr.ecr.ap-southeast-2.amazonaws.com/frontend   <none>            1df1a99e23e4   2 months ago   53MB
registry                                                     2.7.1             b8604a3fe854   3 years ago    26.2MB
centos                                                       8                 5d0da3dc9764   3 years ago    231MB
nginx                                                        1.19.2            7e4d58f0e5f3   5 years ago    133MB
```

3. 以下コマンドを実行する。
```
docker tag {docker imagesで確認したイメージ名}:{イメージタグ} {ホストOSのホスト名}:5000/testimage:v1
```

4. 以下コマンドを実行する(先ほど作成したイメージ以外は省略しています)。
```
$ docker images
REPOSITORY                                                   TAG               IMAGE ID       CREATED        SIZE
test:5000/testimage                                          v1                5d0da3dc9764   3 years ago    231MB
```

5. プラクティスの指示コマンドを実行してください。
6. プラクティスの指示コマンドを実行してください。
7. 以下コマンドを実行する。
```
docker push {ホストOSのホスト名}:5000/testimage:v1
```
8. プラクティスの指示コマンドを実行して確認してください。
9. プラクティスの指示コマンドを実行してください。接続できなかった場合、5.～6.節の操作を別マシンで実施してみてください。
10. 以下コマンドを実行する。
```
$ docker images
REPOSITORY                                                      TAG       IMAGE ID       CREATED       SIZE
{ホストOSのホスト名}:5000/testimage   v1        5d0da3dc9764   4 years ago   231MB
```

11. プラクティスの指示コマンドを実行してください。

</details>

---

[TOP](../README.md)   
前: [イメージの取得/削除](./image-operation.md)  
次: [イメージの作成](./image-build.md)  
