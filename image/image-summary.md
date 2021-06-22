[TOP](../README.md)   
前: [イメージの作成](./image-build.md)  
次: [イメージの手動運搬](./image-transport.md)  

---

# まとめ

ここまでの内容を振り返ります。

1. ``registry:2.7.1``のイメージを使いコンテナをバックグラウンドで実行してください。また、ホストOSの``5000``ポートをコンテナの``5000``ポートに繋いでください。

2. テストイメージをビルドするためのディレクトリを作成し移動してください。

3. 以下のコマンドでindex.htmlを作成してください。
   ``` sh
   echo "self build sita image de ugoitemasu" > index.html
   ```

4. 以下を満たすコンテナイメージをビルドしてください。ビルドするイメージ名は``{ホストOS名}:5000/httpd:selfbuild``としてください。（Dockerfileの記述は[日本語マニュアル](https://docs.docker.jp/engine/reference/builder.html#dockerfile)を参考にする）
   - ベースイメージは``alpine:latest``を使用
   - 以下のコマンドを実行しベースイメージにhttpdをインストール
     ``` sh
     apk update
     apk add apache2
     ```
   - index.htmlを``/var/www/localhost/htdocs/``にコピー
   - ``80``ポートを公開
   - コンテナ起動時の実行コマンドは以下
     ``` sh
     /usr/sbin/httpd -D FOREGROUND
     ```

5. ``{ホストOS名}:5000/httpd:selfbuild``イメージのコンテナをバックグラウンドで起動してください。また、ホストOSの``80``ポートをコンテナの``80``ポートに繋いでください。

6. ホストOSから``curl localhost:8080``で接続してください。``self build sita image de ugoitemasu``が表示されることを確認してください。

7. ``{ホストOS名}:5000/httpd:selfbuild``をプライベートイメージレジストリにpushしてください。

ここからの手順はホストOSに接続可能なもう一台のサーバで作業してください。なお、もう一台のサーバからホストOSのホスト名が名前解決できるように設定しておいてください。

8. もう一台のサーバで``{ホストOS名}:5000/httpd:selfbuild``イメージのコンテナをバックグラウンドで起動してください。また、もう一台のサーバの``80``ポートをコンテナの``80``ポートに繋いでください。

9. もう一台のサーバから``curl localhost:8080``で接続してください。``self build sita image de ugoitemasu``が表示されることを確認してください。

両方のサーバで実施してください。

10. 以下コマンドでコンテナをすべて削除してください。
    ``` sh
    docker rm -f `docker ps -a -q`
    ```

11. 以下コマンドでイメージを削除してください。
    ``` sh
    docker rmi {ホストOS名}:5000/httpd:selfbuild
    ```

12. ホストOSに作成したテストイメージビルド用のディレクトリを削除してください。

また、興味のある方は[イメージの手動運搬](./image-transport.md)も確認してください。

---

[TOP](../README.md)   
前: [イメージの作成](./image-build.md)  
次: [イメージの手動運搬](./image-transport.md)  