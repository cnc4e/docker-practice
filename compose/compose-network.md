[TOP](../README.md)   
前: [docker-composeによるコンテナ起動](./compose-run.md)  
次: [docker-composeによる複数コンテナの連携](./compose-multi.md)  

---

# docker-composeによるネットワーク作成

docker-composeでコンテナを起動するとdockerデフォルトの隔離ネットワーク（bridge）とは別でcompose専用の隔離ネットワークが作成されます。この専用ネットワークは任意の名前で作成できます。

1. ``test-pj``ディレクトリを作成し移動してください。

2. 以下を満たす``docker-compose.yml``を作成してください。（ヒント：composeのネットワーク定義は[日本語マニュアル](https://docs.docker.jp/compose/networking.html)を参考にする。）
   - composeのバージョンは``3``
   - ネットワーク定義
     - ネットワーク名: ``test``
       - driver: ``bridge``
   - サービス定義
     - サービス名： ``web``
       - image: ``nginx:1.19.2``
       - ``ホストの8080``と``コンテナの80``を接続
       - ネットワーク``test``に所属

3. 上記作成した``docker-compose.yml``を使い、コンテナをバックグランドで実行してください。

4. コンテナが動いていることを確認してください。

5. 以下コマンドでコンテナが所属するネットワークとIPアドレスを確認してください。
   ``` sh
   docker inspect {コンテナID}
   ```

6. 以下コマンドでコンテナを起動してください。
   ``` sh
   docker run -d nginx:1.19.2
   ```

7. コンテナが動いていることを確認してください。

8. 以下コマンドでコンテナが所属するネットワークとIPアドレスを確認してください。docker-composeで起動したコンテナとは異なるネットワーク、CIDRであることを確認してください。
   ``` sh
   docker inspect {6.で作成したコンテナID}
   ```

9. docker-composeでコンテナを削除してください。

10. 以下コマンドで残っているコンテナも削除してください。
    ``` sh
    docker rm -f `docker ps -a -q`
    ```

11. `test-pj`ディレクトリを削除してください。

このように、docker-composeでネットワークを作成できます。ちなみに、docker-composeでなくても実は[docker network create](https://docs.docker.jp/engine/reference/commandline/network_create.html)でも作成できます。ただ、docker-composeを使う環境であればnetworkも一緒にcomposeで作ることの方が多いでしょう。networkに何も指定が内場合は``<プロジェクト名>_default``のネットワークを作成します。同じcomposeファイル内のserviceはとくに指定しなくてもすべて``default``のネットワークに属します。

また、``ipam``を使えばネットワークのCIDR等を指定することもできます。ipamの指定方法は[リファレンス](https://docs.docker.jp/compose/compose-file.html#ipam)を参考にしてください。

なお、dockerのデフォルトの隔離ネットワークと同じく、ネットワークのCIDRには注意してください。通信したい外部ネットワークのCIDRとバッティングすると正しく通信できない恐れがあります。

<details>
<summary>
答え(一例です)
</summary>

1. 以下コマンドを実行する。
```
$ mkdir test-pj
$ cd test-pj
```

2. 以下コマンドを実行する。
```
cat <<EOF > docker-compose.yml
version: '3'
services:
  web:
    image: nginx:1.19.2
    ports:
      - "8080:80"
    networks:
      - test
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
CONTAINER ID   IMAGE          COMMAND                  CREATED          STATUS          PORTS                                   NAMES
9c37b24ab443   nginx:1.19.2   "/docker-entrypoint.…"   49 seconds ago   Up 47 seconds   0.0.0.0:8080->80/tcp, :::8080->80/tcp   test-pj-web-1
```

5. プラクティスの指示コマンドを実行して確認してください。
```
$ docker inspect 9c37b24ab443
[
    {
        "Id": "9c37b24ab443e616cef38d3d0f59e06feabc0d09b7ca7d9bdeb4353de66712c2",
~~~~
                    "NetworkID": "51cfd83ba11e488eb3e5a35cceaae161e905dbea9879e6718f860b03deaa32d3",
                    "EndpointID": "2b4f70c0b2d66e51b9481761fd08ffc207b6b64ba1a719a58429afa38d303c06",
                    "Gateway": "172.21.0.1",
                    "IPAddress": "172.21.0.2",
                    "IPPrefixLen": 16,
~~~~
```

6. プラクティスの指示コマンドを実行してください。
7. 4.と同じコマンドを実行して確認してください。
```
$ docker ps
CONTAINER ID   IMAGE          COMMAND                  CREATED          STATUS          PORTS                                   NAMES
074e06b4b10c   nginx:1.19.2   "/docker-entrypoint.…"   22 seconds ago   Up 21 seconds   80/tcp                                  nervous_nightingale
9c37b24ab443   nginx:1.19.2   "/docker-entrypoint.…"   3 minutes ago    Up 3 minutes    0.0.0.0:8080->80/tcp, :::8080->80/tcp   test-pj-web-1
```

8. プラクティスの指示コマンドを実行して確認してください。
```
$ docker inspect 074e06b4b10c
[
    {
        "Id": "074e06b4b10c2974b39fc7bee1dfb9042f8a9fd1de0bbcb30bb8197df88b6255",
~~~~
                    "NetworkID": "1278fead1e961c2bfec457faabf7ee30da78a6462d1f666ac71f108e391919c7",
                    "EndpointID": "2c949c72804d1e74bcb0f98e1ee7ef19b190544c59fa27065af4c389c0d35c4c",
                    "Gateway": "172.17.0.1",
                    "IPAddress": "172.17.0.2",
                    "IPPrefixLen": 16,
~~~~
```

9. 以下コマンドを実行する。
```
docker-compose down
```

10. プラクティスの指示コマンドを実行してください。
11. 以下コマンドを実行する。
```
rm -rf test-pj
```

</details>

---

[TOP](../README.md)   
前: [docker-composeによるコンテナ起動](./compose-run.md)  
次: [docker-composeによる複数コンテナの連携](./compose-multi.md)  
