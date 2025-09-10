[TOP](../README.md)   
前: [ホストOS上の隔離空間であるということ](./container-feature-isolation.md)  
次: [どこでも同じものが動くということ](./container-feature-reproducibility.md)  

--- 

# 一時的であるということ

VMの場合、ファイルシステムに保存したデータは再起動してもそのまま残り続けます。また、IPアドレスなども固定にすることが多いと思います。一方、コンテナの場合、それらはすべて一時的なものです。

1. 以下コマンドでコンテナを作成してください。
   ``` sh
   sudo docker run -d centos:8 /bin/sh -c "sleep 11111"
   ```

2. 以下コマンドでコンテナが動いていることを確認してください。
   ``` sh
   sudo docker ps
   ```

3. 以下コマンドでコンテナにログインしてください。
   ``` sh
   sudo docker exec -it {1つ目コンテナID} sh
   ```

4. コンテナのホスト名、IPアドレスを確認してください。
   ``` sh
   hostname
   ip a
   ```

5. 以下のコマンドで/etc/hostnameを更新し、通常のOSなら次回起動時にホスト名が変わる様に設定してください。
   ``` sh
   echo my-name-is-container > /etc/hostname
   cat /etc/hostname
   ```

6. コンテナからログアウトしてください。
   ``` sh
   exit
   ```

7. コンテナを停止してください。
   ``` sh
   sudo docker stop {1つ目コンテナID}
   ```

ここで1つ目のコンテナのリソースは開放されています。ただ、このままコンテナを再起動するとまた同じIPアドレスが振られてしまいます。IPアドレスの変化が見えやすい様に、コンテナを1つ起動します。

8. 新しいコンテナを作成してください。
   ``` sh
   sudo docker run -d centos:8 /bin/sh -c "sleep 22222"
   ```

9. 停止したコンテナを再起動してください。
    ``` sh
    sudo docker restart {1つ目コンテナID}
    ```

10. コンテナが2つ動いていることを確認してください。
    ``` sh
    sudo docker ps
    ```

11. 1つ目のコンテナにログインして情報を確認してください。ホスト名はもとのコンテナIDのままで、IPアドレスも変わっており、修正したファイルの内容も失われているはずです。
    ``` sh
    sudo docker exec -it {1つ目コンテナID} sh
    hostname
    ip a
    cat /etc/hostname
    exit
    ```

12. コンテナをすべて削除してください。
    ``` sh
    sudo docker rm -f {1つ目コンテナID} {2つ目コンテナID}
    ```

このように、コンテナのファイルシステムは一過性の領域であるため注意が必要です。また、IPアドレスは使い回されるため、特定のコンテナに接続したい場合、IPアドレスだと意図したコンテナに接続できない場合があります。コンテナを扱う上ではこれら``コンテナリソースは一時的なものである``ということを十分に意識してシステムを構築します。たとえば消えて困るデータはコンテナ外のボリュームに保存したり、アクセスはIPアドレスではなく名前解決可能なホスト名にします。

---

[TOP](../README.md)   
前: [ホストOS上の隔離空間であるということ](./container-feature-isolation.md)  
次: [どこでも同じものが動くということ](./container-feature-reproducibility.md)  
