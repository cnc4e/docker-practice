[TOP](../README.md)   
前: -  
次: [イメージレジストリ](./image-registry.md)  

---

# イメージの取得/削除

コンテナはイメージから作成します。このイメージを共有することで目的のアプリケーションをどこででも動かすことができます。イメージは``コンテナレジストリ``というイメージ置き場から取得します。Dockerでは``Docker Hub``というパブリックコンテナレジストリがデフォルトで使われます。``コンテナの基本``でいくつかコンテナを動かしましたが、あれらのコンテナイメージも実はDocker Hubから取得していました。

1. ホストOSにあるコンテナイメージの一覧を表示してください。（ヒント：[docker images](https://docs.docker.jp/engine/reference/commandline/images.html)コマンドを使います。）

2. ``hello-world``イメージをホストOSにダウンロードしてください。（ヒント：[dokcer pull](https://docs.docker.jp/engine/reference/commandline/pull.html)コマンドを使います。）

3. ホストOSにあるコンテナイメージの一覧を表示してください。``hello-world``が追加されていることを確認してください。

4. ``hello-world``イメージを使いコンテナを起動してください。オプション等はつけなくて良いです。このコンテナは``Hello from Docker!``を表示するだけのものです。

5. コンテナを削除してください。（ちなみに、コンテナ起動時のrmオプションをつけていればこの手順を省略できます。）

6. コンテナイメージ``hello-world``を削除してください。（ヒント：[docker rmi](https://docs.docker.jp/engine/reference/commandline/rmi.html)コマンドを使います。）

このように、コンテナイメージのダウンロードや削除ができます。また、上記手順ではコンテナイメージを削除する前にコンテナを削除しました。もしコンテナ削除前にイメージを消そうとしてもとエラーになります。また、わざわざpullしなくてもrun実行時にホストOSの中にイメージがなければ自動でpullしてくれます。なのでわざわざpullするのは稀かもしれません。

なお、実は``hello-world``の様なイメージ名の指定は短縮表記です。正しくは``hello-world:latest``になります。このlatestの部分は``タグ``と言います。タグをとくに指定しない場合、latestが使用されます。たとえば、``コンテナの基本``では``centos:8``や``nginx:1.19.2``というように``<イメージ名>``:``<タグ>``で指定します。

<details>
<summary>
答え(一例です)
</summary>

1. 以下コマンドを実行する。
```
docker images
```

2. 以下コマンドを実行する。
```
docker pull hello-world:latest
```

3. 1.と同じコマンドを実行する。
4. 以下コマンドを実行する。
```
$ docker run hello-world

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```

5. 以下コマンドを実行して削除してください。
```
$ docker ps -a
CONTAINER ID   IMAGE         COMMAND    CREATED         STATUS                     PORTS     NAMES
454afbdccc25   hello-world   "/hello"   5 minutes ago   Exited (0) 5 minutes ago             quirky_bhabha
$ docker rm -f {docker psで確認したコンテナID}
{docker psで確認したコンテナID}
```

6. 以下コマンドを実行する。
```
$ docker rmi {3.節で確認したimage名}
Untagged: hello-world:latest
Untagged: hello-world@sha256:54e66cc1dd1fcb1c3c58bd8017914dbed8701e2d8c74d9262e26bd9cc1642d31
Deleted: sha256:1b44b5a3e06a9aae883e7bf25e45c100be0bb81a0e01b32de604f3ac44711634
Deleted: sha256:53d204b3dc5ddbc129df4ce71996b8168711e211274c785de5e0d4eb68ec3851
```

</details>

---

[TOP](../README.md)   
前: -  
次: [イメージレジストリ](./image-registry.md)  
