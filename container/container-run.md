[TOP](../README.md)   
前: -  
次: [コンテナへのアクセス](./container-access.md)  
次: [ホストOS上の隔離空間であるということ](./container-feature-isolation.md)（時間ある人向け）

---

# コンテナの起動停止

難しいことは置いておいてまずはコンテナを起動してコンテナがどういうものか触れていきましょう。コンテナを起動して停止、削除する方法を学びます。

1. dockerプロセスが動いていることを確認してください。たとえばCentOSなどsystemdで動いている場合は以下のコマンドです。
   ``` sh
   systemctl status docker
   ```

2. 以下のコマンドを実行し、nginxのコンテナをバックグランドで動かしてください。
   ``` sh
   sudo docker run -d nginx:1.19.2
   ```

3. 上記実行した結果コンテナが動いていることを以下コマンドで確認してください。とくに、IMAGEが指定した``nginx:1.19.2``であり、STATUSに``Up {起動時間}``と表示されていることを確認してください。
   ``` sh
   sudo docker ps
   ```

4. コンテナはUpしていますがこれでは動いている実感がありません。コンテナ内にログインしてnginxが動いていることを確認します。以下のようなコマンドでコンテナにログインしてください。{CONTAINER ID}はさきほど実行したdocker psで表示されたIDを指定してください。このコマンドはコンテナに対し追加コマンド（sh）を発行しています。また、``-it``はコンテナと端末の標準入出力をつなぐためのオプションです。この``sudo docker exec -it {CONTAINER ID} sh``はよく使うので覚えておくと良いでしょう。
   ``` sh
   sudo docker exec -it {CONTAINER ID} sh
   # プロンプトが変わればログインできています。
   ```

5. コンテナ内で以下のコマンドを実行し、nginxが動いていることを確認してください。確認できたらログアウトしてください。
   ``` sh
   curl localhost
   # 以下の様な出力されればOK
   # <!DOCTYPE html>
   # <html>
   # <head>
   # <title>Welcome to nginx!</title>
   # ~略~
   exit
   ```

6. コンテナを停止します。{CONTAINER ID}はさきほど実行したdocker psで表示されたIDを指定してください。
   ``` sh
   sudo docker stop {CONTAINER ID}
   ```

7. コンテナの起動状態を確認してください。このとき、以下のようにdocker psコマンドに``-a``のオプションを追加して実行してください。こうすることで停止中のコンテナもすべて確認できます。
   ``` sh
   sudo docker ps -a
   ```

8. 上記のように、コンテナを停止しただけでは一覧に残り続けます。完全に消すには削除を行います。STATUSがExitedしているコンテナを以下のように削除してください。ちなみに、rm -fで動いているコンテナを強制的に停止&削除することもできます。
   ``` sh
   sudo doker rm {CONTAINER ID}
   ```

以上がdockerによるコンテナの基本的な操作です。これだけだとコンテナがどういったものかまだ良くわからないかもしれません。もっとコンテナについて知りたい方は時間ある人向けコンテンツ[ホストOS上の隔離空間であるということ](./container-feature-isolation.md)に進んでください。急ぎの方は[コンテナへのアクセス](./container-access.md)に進んでください。

--- 

[TOP](../README.md)   
前: -  
次: [コンテナへのアクセス](./container-access.md)  
次: [ホストOS上の隔離空間であるということ](./container-feature-isolation.md)（時間ある人向け）
