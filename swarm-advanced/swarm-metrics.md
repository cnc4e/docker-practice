[TOP](../README.md)   
前: [ログ](./swarm-log.md)  
次: [セキュリティ](./swarm-security.md)  

---

# 監視

コンテナのメトリクス（CPU/memory等）情報を収集して可視化できるようにします。コンテナ界隈では[Prometheus](https://prometheus.io/)というツールが良く使われます。Docker公式にもPrometheusを使ったメトリクス収集の方法について解説があります。[こちら](https://docs.docker.com/config/daemon/prometheus/)

上記の通りPrometheusでの方法は公式で案内されているため、その他の手段としてZabbixを使ったメトリクス収集を実装してみます。Zabbixサーバーをコンテナで起動し、Zabbixエージェントをコンテナで各ノードに配置します。エージェントは[zabbix-docker-monitoring](https://github.com/monitoringartist/zabbix-docker-monitoring/tree/master)というものを使用します。

## 1. Zabbixサーバーのインストール

ZabbixをDockerで起動するためのcompose一式が提供されているためそれを使用します。なお、手順は[こちら](https://qiita.com/zembutsu/items/d98099bf68399c56c236)のQiitaを参考にしています。この手順においてはswarmではなく純粋にdocker-composeでコンテナを起動します。そのため任意のノード上でのみZabbixサーバが起動します。

1. mangaer0で以下コマンドを実行しリポジトリをクローンします。

``` sh
git clone https://github.com/zabbix/zabbix-docker.git
cd zabbix-docker
```

2. 隠しファイルで`.MYSQL_PASSWORD`、`.MYSQL_ROOT_PASSWORD`、`.MYSQL_USER`があります。MySQLのユーザ・パスワードを変更したい場合は各ファイルの内容を修正してください。（本プラクティスではとくに修正しないで進めます。）

``` sh
ll -a
```

3. swarmではなく純粋にdocker-composeで起動します。使用するcomposeファイルを`docker-compose.yaml`にリネームします。

``` sh
cp docker-compose_v3_centos_mysql_latest.yaml docker-compose.yaml
```

4. docker-composeでコンテナを起動します。

``` sh
docker-compose --profile all up -d
```

5. コンテナ群が起動したことを確認します。

``` sh
docker ps
```

【表示例】

```
CONTAINER ID   IMAGE                                              COMMAND                  CREATED          STATUS                    PORTS                                                                                  NAMES
f1b1e933d49b   zabbix/zabbix-web-apache-mysql:centos-5.4-latest   "docker-entrypoint.sh"   15 seconds ago   Up 13 seconds (healthy)   0.0.0.0:8443->8443/tcp, :::8443->8443/tcp, 0.0.0.0:8081->8080/tcp, :::8081->8080/tcp   zabbix-docker_zabbix-web-apache-mysql_1
5de68d5716ac   zabbix/zabbix-web-nginx-mysql:centos-5.4-latest    "docker-entrypoint.sh"   15 seconds ago   Up 14 seconds (healthy)   0.0.0.0:80->8080/tcp, :::80->8080/tcp, 0.0.0.0:443->8443/tcp, :::443->8443/tcp         zabbix-docker_zabbix-web-nginx-mysql_1
a69e29d5aba6   zabbix/zabbix-proxy-mysql:centos-5.4-latest        "/sbin/tini -- /usr/…"   16 seconds ago   Up 14 seconds             0.0.0.0:10071->10051/tcp, :::10071->10051/tcp                                          zabbix-docker_zabbix-proxy-mysql_1
0a71c0ca2191   zabbix/zabbix-proxy-sqlite3:centos-5.4-latest      "/sbin/tini -- /usr/…"   16 seconds ago   Up 14 seconds             0.0.0.0:10061->10051/tcp, :::10061->10051/tcp                                          zabbix-docker_zabbix-proxy-sqlite3_1
2c3234443591   zabbix/zabbix-server-mysql:centos-5.4-latest       "/sbin/tini -- /usr/…"   17 seconds ago   Up 15 seconds             0.0.0.0:10051->10051/tcp, :::10051->10051/tcp                                          zabbix-docker_zabbix-server_1
1adf5f16ffdf   zabbix/zabbix-java-gateway:centos-5.4-latest       "docker-entrypoint.s…"   18 seconds ago   Up 16 seconds                                                                                                    zabbix-docker_zabbix-java-gateway_1
519751494fb4   zabbix/zabbix-snmptraps:centos-5.4-latest          "/usr/sbin/snmptrapd…"   18 seconds ago   Up 16 seconds             0.0.0.0:162->1162/udp, :::162->1162/udp                                                zabbix-docker_zabbix-snmptraps_1
699317c49698   mysql:8.0                                          "docker-entrypoint.s…"   18 seconds ago   Up 17 seconds                                                                                                    zabbix-docker_mysql-server_1
3a8e8b0c76d7   zabbix/zabbix-web-service:centos-5.4-latest        "docker-entrypoint.s…"   18 seconds ago   Up 16 seconds                                                                                                    zabbix-docker_zabbix-web-service_1
0eb9d2eebee5   zabbix/zabbix-agent:centos-5.4-latest              "/sbin/tini -- /usr/…"   18 seconds ago   Up 16 seconds                                                                                                    zabbix-docker_zabbix-agent_1
```

6. 作業端末等、manager0に接続できる端末からWebブラウザを立ち上げ`http://<manager0 IP>`で接続します。Zabbixのログイン画面が表示されるはずです。

7. Zabbixのログイン画面でUser:`Admin`、Pass:`zabbix`でログインしてください。

8. このままではagentからの情報をうまく収集できないため以下を行ってください。

  - configuration -> Hosts を選択し、Name:Zabbix serverをクリックしてください。
  - InterfacesのIP Addressを消し、DNS nameに`zabbix-agent`と入力してください。Connect toを`DNS`にしてください。画面下部のUpdateをクリックしてください。
  - Monitoring -> Latest dataを表示しHost: Zabbix serverのメトリクスが収集できていることを確認してください。(Last valueに値が入っていれば取得できてます。)

以上によりmanager0でzabbixサーバーが起動しました。

## 2. Zabbixサーバーのセットアップ

まだagentをworkerに配置していませんが先にagentの設定をしておきます。また、送られてくる情報を表示するためテンプレートの登録もします。

### 2-1. agent登録

以下手順ですべてのworkerを追加してください。

1. configuration -> Hosts を表示しCreate hostを選択

2. 以下情報を入力

- Host name: workerノードのプライベートDNS（例：ip-10-0-1-189.us-east-2.compute.internal）
- Visible name: わかりやすい表示名を入力（Host nameと一緒でも良いです。）
- Groups: 何でも良いです。例として`Linux servers`を選択
- Interfaces: add -> agent
  - IP address: workerノードのプライベートIP
  - DNS name: 空
  - Connect to: IP
  - Port: 10050

### 2-2. テンプレート追加

1. [https://raw.githubusercontent.com/monitoringartist/zabbix-docker-monitoring/master/template/Zabbix-Template-App-Docker.xml](https://raw.githubusercontent.com/monitoringartist/zabbix-docker-monitoring/master/template/Zabbix-Template-App-Docker.xml)を作業端末にダウンロードしてください。

2. ダウンロードしたファイルを修正します。102-104行目を以下のように修正します。（importする時にエラーが出るための修正です。）

【修正前】

``` xml
                            <valuemap>
                                <name>Service state</name>
                            </valuemap>
```

【修正後】

``` xml
                            <valuemap/>
```

> ダウンロードしたままのテンプレートだとなぜか上記valuemapでエラーとなるためこの修正で回避しています。

3. **Zabbixサーバー** configuration -> template を表示しImportを選択します。

4. **Zabbixサーバー** import fileで先ほど端末にダウンロードしたテンプレートを選択してimportします。

5. **Zabbixサーバー** configuration -> Hostsを表示し、Workerノードを選択してください。

6. **Zabbixサーバー** Templatesタブを表示しLink new templatesで先ほどimportした`Template App Docker - www.monitoringartist.com`を選択してupdateしてください。

## 3. workerへagentの配布

1. 以下満たすcomposeファイル`dockbix-agent.yaml`を作成してください。（[ヒント](https://docs.docker.com/compose/compose-file/compose-file-v3/#host-or-none)）

- service: dockbix-agent
  - image: monitoringartist/dockbix-agent-xxl-limited:latest
  - deploy: global
  - volumes: /を/rootfs、/var/runを/var/runにマウント
  - environment: ZA_ServerとZA_ServerActiveにZabbixサーバーをインストールしたIPアドレスを設定
  - networks: hostnetに所属
- networks: hostnet
  - すでにあるhostという名前のネットワークを指定

> **特権モード(privileged)について**  
> agentとして使用しているzabbix-docker-monitoringの公式手順ではprivilegedをつけてコンテナを起動しています。[ネタ元](https://github.com/monitoringartist/zabbix-docker-monitoring)  
> しかし、Swarmではprivikegedコンテナを起動しようとしても`Ignoring unsupported option:privileged`となり起動できません。  
> そのため、本プラクティスではprivilegedを付けないでコンテナを起動しています。なお、privilegedなしでもこの後の手順は問題なく実施できます。  
> また、privilegedコンテナは特権を許すためセキュリティ面で安全といえません。ワークロードのコンテナではprivilegedは設定しないようにしましょう。

> **hostネットワークに接続するのはなぜですか？**  
> Zabbixサーバーでhostを登録した時にworkerノードのプライベートDNSで登録したと思います。そのため、agentのホスト名を実行しているworkerノードのホスト名と同じにするためです。

2. 上記作成したcomposeファイルを指定し、スタック`zabbix`を作成してください。

3. スタックの一覧、スタック内のサービス一覧、スタック内のタスク一覧をそれぞれ表示し、タスクがすべてのworkerノードにデプロイされていることを確認してください。

4. **Zabbixサーバー** Monitoring -> Latest data を表示してください。hostsにworkerノードのホスト名を入力してapplyするとそのworker上で動いているコンテナのメトリクスが確認できるはずです。

## 4. 後片付け

1. スタック`zabbix`を削除してください。

2. mangaer0に接続し、`docker-compose.yaml`があるディレクトリに移動し、以下コマンドでZabbixサーバーを削除してください。

``` sh
docker-compose down
```

3. gitクローンした`zabbix-docker`ディレクトリを削除してください。

*[解答例](./.ans/swarm-metrics.md)*

---

[TOP](../README.md)   
前: [ログ](./swarm-log.md)  
次: [セキュリティ](./swarm-security.md)  
