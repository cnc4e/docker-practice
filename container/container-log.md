[TOP](../README.md)   
前: [コンテナに環境変数を設定](./container-env.md)  
次: [まとめ](./container-summary.md)  

---

# コンテナのログ

コンテナのログはコンテナ実行コマンドの標準出力と標準エラー出力の内容です。

1. ``nginx:1.19.2``のイメージを使いコンテナをバックグラウンドで実行してください。コンテナの80をホストOSの8080に接続してください。

2. ホストOSからコンテナにcurlを実行してください。

3. コンテナのログを表示し、``172.17.0.1``からのアクセスメッセージを確認してください。（ヒント：ログは[docker logs](https://docs.docker.jp/engine/reference/commandline/logs.html)で表示できます。）

このようにコンテナのログを確認できます。このログはjson形式でホストOS内にあります。

4. 以下のコマンドでコンテナログの場所を確認してください。
   ``` sh
   docker inspect {コンテナID} | grep LogPath
   ```

5. ホストOSにあるログファイルの内容を表示してください。jsonに整形されたログが表示されることを確認してください。

6. コンテナを削除してください。

7. さきほど確認したログファイルを確認してください。``ログファイルが存在しないこと``を確認してください。

このように、ログはホストOSでも確認できますが、コンテナが削除されると一緒に消えてしまうので注意してください。また、json形式のログはコンテナが動き続けると無尽蔵に肥大化します。これを防ぐため、ローテート設定（ファイルサイズ、世代数）を指定できます。

8. ``nginx:1.19.2``のイメージを使いコンテナをバックグラウンドで実行してください。コンテナの80をホストOSの8080に接続してください。また、ログの``ファイルサイズを10MB``、``世代数を2``に指定してください。（ヒント：ログの設定は[docker runのオプション](https://docs.docker.jp/engine/admin/logging/overview.html?highlight=%E3%83%AD%E3%82%AE%E3%83%B3%E3%82%B0#json)で指定できます。）

9. 以下コマンドでログ設定を確認してください。
   ``` sh
   docker inspect {コンテナID} | grep -e max-file -e max-size
   ```

10. コンテナを削除してください。

デフォルトでは``json-file``のロギングドライバを使用しています。ロギングドライバを変えることもできます。

11. ``nginx:1.19.2``のイメージを使いコンテナをバックグラウンドで実行してください。コンテナの80をホストOSの8080に接続してください。また、ロギングドライバを``journald``に指定してください。（ヒント：ログの設定は[docker runのオプション](https://docs.docker.jp/engine/admin/logging/overview.html?highlight=%E3%83%AD%E3%82%AE%E3%83%B3%E3%82%B0#id1)で指定できます。）

12. 以下コマンドでコンテナのロギングドライバを確認してください。
   ``` sh
   docker inspect {コンテナID} | grep Type
   ```

13. ホストOSからコンテナにcurlを実行してください。

14. ホストOSで以下のコマンドを実行しジャーナルログを確認してください。
   ``` sh
   journalctl -xe
   ```

15. 以下コマンドですべてのコンテナを削除してください。
    ``` sh
    docker rm -f `docker ps -a -q`
    ```

今回はコンテナ起動時にロギングドライバの指定や設定をしましたが、デフォルトのロギングドライバを変更することもできます。やり方は[日本語マニュアル](https://docs.docker.jp/config/container/logging/configure.html#configure-the-default-logging-driver)を確認ください。また、ロギングドライバはDockerのエディションにより利用制限があるため注意してください。無料版のCEでは``local``、``json-file``、``journald``の3つが対応しています。

また、``アプリケーションのログはログファイルではなく、標準出力および標準エラー出力に表示``するよう開発してください。そうしないとコンテナ内のログファイルを収集する仕組みなどの実装が必要かもしれません。


<details>
<summary>
答え(一例です)
</summary>

1. 以下コマンドを実行する。
```
docker run -d -p 8080:80 nginx:1.19.2 sh -c "nginx && sleep 3600"
```

2. 以下コマンドを実行する。
```
$ curl localhost:8080
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

3. 以下コマンドを実行する。
```
$ docker ps
CONTAINER ID   IMAGE          COMMAND                  CREATED          STATUS          PORTS                                   NAMES
50cbf3f73989   nginx:1.19.2   "/docker-entrypoint.…"   3 minutes ago    Up 3 minutes    0.0.0.0:8080->80/tcp, :::8080->80/tcp   busy_rhodes
$ docker logs {docker psで確認したコンテナID}
172.17.0.1 - - [10/Sep/2025:09:45:33 +0000] "GET / HTTP/1.1" 200 612 "-" "curl/8.5.0" "-"
```

4. プラクティスの指示コマンドを実行してください。
5. 4.節で表示されたところまでで以下のように`cat`コマンドを実行してください。
```
$ sudo cat /var/lib/docker/containers/50cbf3f73989ff61041a7bf17572d9bba3994e3cd7184a816a1948a749606192/50cbf3f73989ff61041a7bf17572d9bba3994e3cd7184a816a1948a749606192-json.log
{"log":"172.17.0.1 - - [10/Sep/2025:09:45:33 +0000] \"GET / HTTP/1.1\" 200 612 \"-\" \"curl/8.5.0\" \"-\"\n","stream":"stdout","time":"2025-09-10T09:45:33.995202795Z"}
```

6. 以下コマンドを実行する。
```
$ docker rm -f {docker psで確認したコンテナID}
{docker psで確認したコンテナID}
```

7. 5.節で実施したコマンドを再度実行してください。
```
$ sudo cat /var/lib/docker/containers/50cbf3f73989ff61041a7bf17572d9bba3994e3cd7184a816a1948a749606192/50cbf3f73989ff61041a7bf17572d9bba3994e3cd7184a816a1948a749606192-json.log
cat: /var/lib/docker/containers/50cbf3f73989ff61041a7bf17572d9bba3994e3cd7184a816a1948a749606192/50cbf3f73989ff61041a7bf17572d9bba3994e3cd7184a816a1948a749606192-json.log: No such file or directory
```

8. 以下コマンドを実行する。
```
docker run -d -p 8080:80 --log-opt max-size=10m --log-opt max-file=2 nginx:1.19.2 sh -c "nginx &&
 sleep 3600"
```

9. プラクティスの指示コマンドを実行してください。
10. 以下コマンドを実行する。
```
docker rm -f {docker psで確認したコンテナID}
{docker psで確認したコンテナID}
```

11. 以下コマンドを実行する。
```
docker run -d -p 8080:80 --log-driver=journald nginx:1.19.2 sh -c "nginx && sleep 3600"
```

12. プラクティスの指示コマンドを実行してください。
13. 以下コマンドを実行する。
```
curl localhost:8080
```

14. プラクティスの指示コマンドを実行してください。curlコマンドのログが確認できない場合、以下のコマンドで見られる可能性があります。
```
$ sudo journalctl CONTAINER_ID={docker psで確認したコンテナID}
Sep 11 06:56:08 ip-10-0-10-220.ap-southeast-2.compute.internal 6390404c2fa2[2328]: 172.17.0.1 - - [11/Sep/2025:06:56:08 +0000] "GET / HTTP/>
Sep 11 07:03:39 ip-10-0-10-220.ap-southeast-2.compute.internal 6390404c2fa2[2328]: 172.17.0.1 - - [11/Sep/2025:07:03:39 +0000] "GET / HTTP/>
Sep 11 07:05:59 ip-10-0-10-220.ap-southeast-2.compute.internal 6390404c2fa2[2328]: 172.17.0.1 - - [11/Sep/2025:07:05:59 +0000] "GET / HTTP/>
Sep 11 07:09:20 ip-10-0-10-220.ap-southeast-2.compute.internal 6390404c2fa2[2328]: 172.17.0.1 - - [11/Sep/2025:07:09:20 +0000] "GET / HTTP/>
```

15.  プラクティスの指示コマンドを実行してください。


</details>

---

[TOP](../README.md)   
前: [コンテナに環境変数を設定](./container-env.md)  
次: [まとめ](./container-summary.md)  
