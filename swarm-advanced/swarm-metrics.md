[TOP](../README.md)   
前: [ログ](./swarm-log.md)  
次: [準備中]()  

---

# 監視


## 1. Zabbixサーバーのセットアップ

ZabbixをDockerで起動するためのcompose一式が提供されているためそれを使用します。なお、手順は[こちら](https://qiita.com/zembutsu/items/d98099bf68399c56c236)のQiitaを参考にしています。この手順ではswarmではなく純粋にdocker-composeでコンテナを起動します。そのため任意のノード上でのみZabbixサーバが起動します。

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
  - InterfacesのIP Addressを消し、DNS nameに`zabbix-agent`と入力してください。Connect toをDNSにして画面下部のUpdateをクリックしてください。
  - Monitoring -> Latest dataを表示しHost: Zabbix serverのメトリクスが収集できていることを確認してください。(Last valueに値が入っていれば取得できてます。)

以上によりmanager0でzabbixサーバーが起動しました。

## 2.workerへagentの配布

https://dev.classmethod.jp/articles/zabbix-docker-monitoring/
https://hawksnowlog.blogspot.com/2019/06/monitor-containers-with-zabbix-docker-monitoring.html
https://github.com/monitoringartist/zabbix-docker-monitoring/tree/master


``` sh
docker run \
  --name=dockbix-agent-xxl \
  --net=host \
  --privileged \
  -v /:/rootfs \
  -v /var/run:/var/run \
  --restart unless-stopped \
  -e "ZA_Server=10.0.1.229" \
  -e "ZA_ServerActive=10.0.1.229" \
  -d monitoringartist/dockbix-agent-xxl-limited:latest
```

``` sh
docker run \
  --name=dockbix-agent-xxl \
  --net=host \
  --privileged \
  -p 10050:10050 \
  -v /:/rootfs \
  -v /var/run:/var/run \
  --restart unless-stopped \
  -e "ZA_Server=10.0.1.229" \
  -e "ZA_ServerActive=10.0.1.229" \
  -d monitoringartist/dockbix-agent-xxl-limited:latest
```


```

```

https://raw.githubusercontent.com/monitoringartist/zabbix-docker-monitoring/master/template/Zabbix-Template-App-Docker.xml
https://raw.githubusercontent.com/monitoringartist/zabbix-docker-monitoring/master/template/Zabbix-Template-App-Docker.xml

---

[TOP](../README.md)   
前: [ログ](./swarm-log.md)  
次: [準備中]()  
