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

このように、同じネットワークであればサービス名でアクセスできます。コンテナ内部の設定はあらかじめサービス名で通信するように設定しておけばコンテナを何度再作成してもIPアドレスを気にする必要はありません。

---

[TOP](../README.md)  
前: [docker-composeによるネットワーク作成](./compose-network.md)  
次: [まとめ](./compose-summary.md)  
