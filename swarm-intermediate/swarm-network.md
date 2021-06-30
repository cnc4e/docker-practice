[TOP](../README.md)   
前: -  
次: [コンフィグの使用](./swarm-config.md)  

---

`ここから初級で扱った内容のヒントは省略します。`

# ネットワーク

## overlayネットワークの基本

通常のスタンドアロンDockerの場合、Dockerのbridgeネットワークは各ホスト内に独立して構成されます。そのため、別のホスト上で動いているコンテナにアクセスするにはコンテナとホストのポートを接続しホストポートにアクセスする必要がありました。（bridgeネットワークについては[こちら](https://docs.docker.com/network/bridge/)）

Swarmでは複数のホストにまたがる仮想的なネットワークを構成します。これをoverlayネットワークと言います。overlayネットワークの内コンテナは別々のホストでもコンテナIPまたはサービス名でアクセスできます。

1. ワーカーノードそれぞれに一意に判別できるラベルを付与してください。（例： name:worker0 / name:worker1）

2. 以下満たすcomposeファイル`network-overlay.yaml`を作成してください。

- service名: service1
  - image: nginx
  - deploy mode: replicated
  - replicas: 1
  - constraint: worker0を指定
- service名: service2
  - image: httpd
  - deploy mode: replicated
  - replicas: 1
  - constraint: worker1を指定

3. 上記作成したcomposeファイルを指定し、スタック`test`を作成してください。

4. スタックの一覧、スタック内のサービス一覧、スタック内のタスク一覧をそれぞれ表示し、タスクが2つデプロイされていることを確認してください。また、各サービスのタスクが別々のワーカーノードにスケジュールされていることを確認してください。

5. ネットワークの一覧を表示し、スタック`test`用のoverlayネットワークが作成されていることを確認してください。（[ヒント](https://docs.docker.com/engine/reference/commandline/network_ls/)）

6. スタック`test`用のoverlayネットワークの詳細を表示してください。ネットワークのサブネットがSwarm構成時に指定したオーバレイネットワークのアドレス帯に収まるネットワークであることを確認してください。（[ヒント](https://docs.docker.com/engine/reference/commandline/network_inspect/)）

7. 各サービスの詳細を表示してください。タスクのIPアドレスが上記スタック`test`用のoverlayネットワークのアドレスであることを確認してください。test_service2のタスクのIPアドレスは控えておいてください。次の手順で使用します。

8. **worker0にログイン**し以下のコマンドを実行してください。別ノードで動いているservice2のhttpdにアクセスできることを確認してください。

``` sh
docker exec <container id> curl -s test_service2
docker exec <container id> curl -s <test_service2のタスクIPアドレス>
```

このようにoverlayネットワーク内のタスクはノードを気にしないでアクセスできます。composeでスタックを作成すると`スタック名_default`という名前のネットワークが自動で作成されます。なお、サービス名やIPアドレスでアクセスできるのは同じoverlayネットワークに所属しているタスク間だけです。たとえば上記スタック`test`と別にスタック`test2`を作成した場合、スタック`test`のタスクからスタック`test2`のタスクへは通信できません。

9. composeファイル`network-overlay.yaml`を指定してスタック`test2`を作成してください。

10. スタックの一覧、スタック内のサービス一覧、スタック内のタスク一覧をそれぞれ表示し、タスクが2つデプロイされていることを確認してください。また、各サービスのタスクが別々のワーカーノードにスケジュールされていることを確認してください。

11. スタック`test2`の各サービスの詳細を表示してください。タスクのIPアドレスを確認してください。

12. **worker0にログイン**し以下のコマンドを実行してください。`container id`はスタック`test`でデプロイしたコンテナをしてください。別overlayネットワークのを通信ができないことを確認してください。

``` sh
docker exec <container id> curl test2_service1
docker exec <container id> curl test2_service2
docker exec <container id> curl <test2_service1のIP>
docker exec <container id> curl <test2_service2のIP>
```

12. スタック`test`、`test2`を削除してください。

## overlayネットワークの作成

composeファイルでとくにネットワークを指定しない場合、デフォルトで`スタック名_default`というネットワークを作成します。composeファイで指定すれば任意の名前のoverlayネットワークを構成できます。また、タスクに複数のネットワークをつけることもできます。

1. 以下満たすcomposeファイル`network-create.yaml`を作成してください。（[ヒント①](https://docs.docker.com/compose/compose-file/compose-file-v3/#networks)、[ヒント②](https://docs.docker.com/compose/compose-file/compose-file-v3/#network-configuration-reference)）

- service名: service1
  - image: nginx
  - deploy mode: replicated
  - replicas: 1
  - networks: network1、common
- service名: service2
  - image: httpd
  - deploy mode: replicated
  - replicas: 1
  - networks: network2、common
- service名: service3
  - image: httpd
  - deploy mode: replicated
  - replicas: 1
  - networks: network3
- network名: network1
  - driver: overlay
- network名: network2
  - driver: overlay
- network名: network3
  - driver: overlay
- network名: common
  - driver: overlay

1. 上記作成したcomposeファイルを指定し、スタック`test`を作成してください。

2. スタックの一覧、スタック内のサービス一覧、スタック内のタスク一覧をそれぞれ表示し、タスクが3つデプロイされていることを確認してください。

3. ネットワークの一覧を表示し、スタック`test`のネットワークが3つ作成されていることを確認してください。

4. スタック`test`の各ネットワークの詳細を表示し、Subnetを確認してください。別々のアドレス帯がふられていることを確認してください。

5. 各サービスの詳細を表示してください。test_service1.1およびtest_service2.1にIPアドレスが2つ、test_service3.1に1つ付与されていることを確認してください。

6. **test_service1.1のタスクを実行しているノードにログイン**し以下のコマンドを実行してください。それぞれコメントの結果となることを確認してください。

``` sh
docker exec <container id> curl -s test_service2 # OK
docker exec <container id> curl -s test_service3 # NG
docker exec <container id> curl -s <test_service2のcommonのIP> # OK
docker exec <container id> curl -s <test_service2のnetwork2のIP> # NG
docker exec <container id> curl -s <test_service3のnetwork3のIP> # NG
```

以上のように、1つのスタックで複数のネットワークを構成できます。同じネットワークに属するサービスは通信できます。同じネットワークに属していないサービスは同じスタックでも通信できません。

また、別のスタックで作成したネットワークに接続もできます。

7. 以下満たすcomposeファイル`network-external.yaml`を作成してください。

- service名: service1
  - image: nginx
  - deploy mode: replicated
  - replicas: 1
  - networks: test_common
- network名: test_common
  - driver: overlay
  - external: true

8. 上記作成したcomposeファイルを指定し、スタック`test2`を作成してください。

9. スタックの一覧、スタック内のサービス一覧、スタック内のタスク一覧をそれぞれ表示し、タスクが1つデプロイされていることを確認してください。

10. ネットワークの一覧を表示し、スタック`test2`のネットワークが作成されて**いない**ことを確認してください。

11. スタック`test2`のサービスの詳細を表示してください。test2_service1.1のIPアドレスがtest_commnのアドレス帯から払い出されていることを確認してください。

12. **test2_service1.1のタスクを実行しているノードにログイン**し以下のコマンドを実行してください。それぞれコメントの結果となることを確認してください。

``` sh
docker exec <container id> curl -s test_service1 # OK
docker exec <container id> curl -s test_service2 # OK
docker exec <container id> curl -s test_service3 # NG
docker exec <container id> curl -s <test_service2のcommonのIP> # OK
docker exec <container id> curl -s <test_service2のnetwork2のIP> # NG
docker exec <container id> curl -s <test_service3のnetwork3のIP> # NG
```

13. スタック`test`および`test2`を削除してください。

以上のように、別のスタックで作成したネットワークにつなぐこともできます。（ただ、これをやってしまうと別のスタックに依存することとなるのであまり良くないかも。やるにしてもネットワーク作成用のスタックを作ってやるとかが良いのかな。）

---

[TOP](../README.md)   
前: -  
次: [コンフィグの使用](./swarm-config.md)  