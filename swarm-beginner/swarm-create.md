[TOP](../README.md)   
前: -  
次: [サービスの作成](./swarm-service.md)  

---

# Swarmクラスタの構築

Swarmは複数のDockerホストに跨るコンテナの配置や自動再作成を行うコンテナオーケストレーションです。SwarmはDockerエンジンに組み込まれているため、Dcokerがインストールされていれば追加のパッケージ等をインストールしなくても使用できます。デフォルトのDockerはSwarmモードが無効になっているのでこれを有効します。

## クラスタ構成について

Swarmクラスタは大きく2つの役割を担うノードで構成されます。`マネージャ`と`ワーカー`です。（[ネタ元](https://docs.docker.com/engine/swarm/how-swarm-mode-works/nodes/)）  

`マネージャ`はクラスタの情報保持やコンテナをどのノードで起動するか割り当てを決めます。この割り当ての処理をコンテナオーケストレータではスケジュールすると言います。`マネージャ`はクラスタを維持するのに重要な役割を担います。そのため、本番環境などでは奇数台（3台or5台）で構成することが推奨されています。（[ネタ元](https://docs.docker.com/engine/swarm/how-swarm-mode-works/nodes/#manager-nodes)）  

`ワーカー`はワークロードのコンテナを動かすノードです。2台以上構成することで負荷分散、可用性の向上を狙えます。

本プラクティスは本番環境を見据え、以下ノード群でクラスタを構成します。OSはCentOS8を使用します。サーバーのスペックはすべてAWSのt2.medium(cpu:2、memory:2G)で動かします。（スペックは環境にあわせて変えてください。）

環境構築用のterraformコードを用意しています。
利用する場合は[環境構築用Terraform](../terraform/guide.md)を参照してください。

|ノード種別|ホスト名|IPアドレス|
|-|-|-|
|マネージャ|manager0|10.0.1.229|
|マネージャ|manager1|10.0.1.246|
|マネージャ|manager2|10.0.1.157|
|ワーカー|worker0|10.0.1.189|
|ワーカー|worker1|10.0.1.181|

## 通信要件

Swarmクラスタを構成するにあたり、以下通信をクラスタ内のすべてのノード間で有効にしてください。

|No|プロトコル|port|用途|ネタ元|
|-|-|-|-|-|
|1|tcp|2377|クラスタ管理通信|[こちら](https://docs.docker.com/engine/swarm/swarm-tutorial/#open-protocols-and-ports-between-the-hosts)|
|2|tcp/udp|7946|ノード間の通信用|[こちら](https://docs.docker.com/engine/swarm/swarm-tutorial/#open-protocols-and-ports-between-the-hosts)|
|3|udp|4789|オーバーレイ ネットワーク トラフィック用|[こちら](https://docs.docker.com/engine/swarm/swarm-tutorial/#open-protocols-and-ports-between-the-hosts)|

## 構築手順

Swarmクラスタを構築する手順を解説します。手順を始める前にすべてのノードにDockerエンジンおよびdocker-composeをインストールしておいてください。インストールの方法については以下の公式マニュアル等を確認ください。各ノードはインターネットに接続できる前提です。また、手順は基本的に各ノードの**rootで実施**します。

- [dockerエンジン](https://docs.docker.com/engine/install/)
- [docker-compose](https://docs.docker.com/compose/install/)

### マネージャ1台目

まずはmanager0に接続して`docker swarm init`を実行します。`docker swarm init`により行われることは[こちら](https://docs.docker.com/engine/swarm/swarm-mode/#create-a-swarm)のドキュメントにあります。とくに注意すべき点は以下です。

- ノードスケジュールの有効
- オーバーレイネットワークのアドレス帯

**ノードスケジュールの有効**はデフォルトではマネージャにもワークロードのコンテナがスケジュールされことを意味します。ワークロードコンテナが影響しマネージャ機能を損なわような事態を回避するため、マネージャとワーカーを完全に分離した方が良いです。そのため後ほどマネージャノードをマネージャ専用とする設定をします。（[マネージャのスケジュール無効化](#マネージャのスケジュール無効化)）

**オーバーレイネットワークのアドレス帯**はデフォルトでは`10.0.0.0/8`が使用されます。オーバーレイネットワークとはSwarmで動かすコンテナが所属するネットワークです。ワーカーノードを束ねた仮想的なネットワークです。（詳しくは[こちら](https://docs.docker.com/network/overlay/)）  
このオーバーレイネットワークのアドレス帯には注意が必要です。もし既設ネットワークのアドレス帯と重複している場合、ネットワークの疎通が正しくできなくなるかもしれません。これを回避するには重複しないアドレス帯を指定することです。アドレス帯の指定はinit時のオプションで`--default-addr-pool`を指定して行います。オーバーレイネットワークを新たに作成するとそのアドレス帯からデフォルトでは`/24`のサブネットを切り出し、オーバーレイネットワークに割り当てられます。このサブネットの大きさはinitオプションの`--default-addr-pool-mask-len`で指定できます。（[ネタ元](https://docs.docker.com/engine/swarm/swarm-mode/#configuring-default-address-pools)）  
長くなりましたが大事なのは`10.0.0.0/8`が既設ネットワークと重複するかどうかです。重複する場合はinitオプションで`--default-addr-pool`のアドレス帯を変更しましょう。

以下コマンドでSwarmクラスタを構成します。アドレスプールを`172.16.0.0/16`に変更しています。`--advertise-addr`で指定するIPアドレスはmanager0のプライベートIPです。出力結果に出てくる`docker swarm join ~`のコマンドはコピーしておきます。後ほど**ワーカー**を参加させるときに使います。

【コマンド】

``` sh
docker swarm init --default-addr-pool 172.16.0.0/16 --advertise-addr 10.0.1.229
```

【出力例】

```
Swarm initialized: current node (jiimcwyswjk9xny5o13dws3cs) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-37hea3dvmqp0u7iwrzob7kqbaqmx6am5vkznf9d0xy0ctd81sw-e6kud9rpoypqrna03j4ktvls8 10.0.1.229:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.
```

上記出力結果に出てくる`docker swarm join ~`のコマンドは**ワーカー参加用のコマンド**としてコピーしておきます。後ほど**ワーカー**を参加させるときに使います。

続いて他のマネージャノードをクラスタに参加させるためのコマンドを生成します。出力結果に出てくる`docker swarm join ~`のコマンドはコピーしておきます。後ほど他の**マネージャ**を参加させるときに使います。

【コマンド】

``` sh
docker swarm join-token manager
```

【出力例】

```
To add a manager to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-37hea3dvmqp0u7iwrzob7kqbaqmx6am5vkznf9d0xy0ctd81sw-a8k2wo7ibizfpd4shum1vosz3 10.0.1.229:2377
```

上記出力結果に出てくる`docker swarm join ~`のコマンドは**マネージャ参加用のコマンド**としてコピーしておきます。後ほど**マネージャ**を参加させるときに使います。

### マネージャ2,3台目

manager1,manager2に接続してさきほどmanager0で生成した**マネージャ参加用のコマンド**をそのまま実行します。

【コマンド】

``` sh
docker swarm join --token SWMTKN-1-37hea3dvmqp0u7iwrzob7kqbaqmx6am5vkznf9d0xy0ctd81sw-a8k2wo7ibizfpd4shum1vosz3 10.0.1.229:2377
```

すべてのノードでコマンドを実行したらいずれかのマネージャノードで以下コマンドを実行し、ノードがクラスタに参加できていることを確認します。

【コマンド】

``` sh
docker node list
```

【出力例】

```
ID                            HOSTNAME                                   STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
s9sdag8f13e0cd99rbq6h8k29 *   ip-10-0-1-157.us-east-2.compute.internal   Ready     Active         Reachable        20.10.7
jiimcwyswjk9xny5o13dws3cs     ip-10-0-1-229.us-east-2.compute.internal   Ready     Active         Leader           20.10.7
uetgfd3snwmbtz8kt4chmejsp     ip-10-0-1-246.us-east-2.compute.internal   Ready     Active         Reachable        20.10.7
```

### マネージャのスケジュール無効化

デフォルトではマネージャにもワークロードコンテナがスケジュールされます。これを防ぐため以下コマンドでマネージャノードはマネージャ専用とします。（[ネタ元](https://docs.docker.com/engine/swarm/admin_guide/#run-manager-only-nodes)）

いずれかのマネージャノードで以下コマンドを実行します。

【コマンド】

``` sh
docker node update --availability drain <manager0 hostname>
docker node update --availability drain <manager1 hostname>
docker node update --availability drain <manager2 hostname>
```

上記実行後ノードを確認します。マネージャノードの`AVAILABILITY`が`Drain`になっていれば良いです。`Drain`は新たにタスク(コンテナ)が割り当てられない状態になります。（[ネタ元](https://docs.docker.com/engine/swarm/swarm-tutorial/drain-node/)）

【コマンド】

``` sh
docker node list
```

【出力例】

```
ID                            HOSTNAME                                   STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
s9sdag8f13e0cd99rbq6h8k29     ip-10-0-1-157.us-east-2.compute.internal   Ready     Drain          Reachable        20.10.7
jiimcwyswjk9xny5o13dws3cs *   ip-10-0-1-229.us-east-2.compute.internal   Ready     Drain          Leader           20.10.7
uetgfd3snwmbtz8kt4chmejsp     ip-10-0-1-246.us-east-2.compute.internal   Ready     Drain          Reachable        20.10.7
```

### ワーカー

worker0とworker1に接続し、manager0で`docker swarm init`したときの出力にあった**ワーカー参加用のコマンド**を実行します。

【コマンド】

``` sh
docker swarm join --token SWMTKN-1-37hea3dvmqp0u7iwrzob7kqbaqmx6am5vkznf9d0xy0ctd81sw-e6kud9rpoypqrna03j4ktvls8 10.0.1.229:2377
```

いずれかのマネージャノードで以下コマンドを実行し、ワーカーもクラスタに参加できていることを確認します。

【コマンド】

``` sh
docker node list
```

【出力例】

```
ID                            HOSTNAME                                   STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
s9sdag8f13e0cd99rbq6h8k29     ip-10-0-1-157.us-east-2.compute.internal   Ready     Drain          Reachable        20.10.7
up8332njsuy8jsi7skecyj1nv     ip-10-0-1-181.us-east-2.compute.internal   Ready     Active                          20.10.7
ct2c1lvonghpq945diq60pi89     ip-10-0-1-189.us-east-2.compute.internal   Ready     Active                          20.10.7
jiimcwyswjk9xny5o13dws3cs *   ip-10-0-1-229.us-east-2.compute.internal   Ready     Drain          Leader           20.10.7
uetgfd3snwmbtz8kt4chmejsp     ip-10-0-1-246.us-east-2.compute.internal   Ready     Drain          Reachable        20.10.7
```


以上でSwarmクラスタの基本的な構成は終わりです。次回からはSwarmクラスタでコンテナを動かす方法を学びます。

---

[TOP](../README.md)   
前: -  
次: [サービスの作成](./swarm-service.md)  