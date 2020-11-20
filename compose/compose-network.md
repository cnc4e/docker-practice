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
   dokcer run -d nginx:1.19.2
   ```

7. コンテナが動いていることを確認してください。

8. 以下コマンドでコンテナが所属するネットワークとIPアドレスを確認してください。docker-composeで起動したコンテナとは異なるネットワーク、CIDRであることを確認してください。
   ``` sh
   docker inspect {コンテナID}
   ```

9. docker-composeでコンテナを削除してください。

10. 以下コマンドで残っているコンテナも削除してください。
    ``` sh
    docker rm -f `docker ps -a -q`
    ```

このように、docker-composeでネットワークを作成できます。ちなみに、docker-composeでなくても実は[docker network create](https://docs.docker.jp/engine/reference/commandline/network_create.html)でも作成できます。ただ、docker-composeを使う環境であればnetworkも一緒にcomposeで作ることの方が多いでしょう。networkに何も指定が内場合は``<プロジェクト名>_default``のネットワークを作成します。同じcomposeファイル内のserviceはとくに指定しなくてもすべて``default``のネットワークに属します。

また、``ipam``を使えばネットワークのCIDR等を指定することもできます。ipamの指定方法は[リファレンス](https://docs.docker.jp/compose/compose-file.html#ipam)を参考にしてください。

なお、dockerのデフォルトの隔離ネットワークと同じく、ネットワークのCIDRには注意してください。通信したい外部ネットワークのCIDRとバッティングすると正しく通信できない恐れがあります。

---

[TOP](../README.md)   
前: [docker-composeによるコンテナ起動](./compose-run.md)  
次: [docker-composeによる複数コンテナの連携](./compose-multi.md)  
