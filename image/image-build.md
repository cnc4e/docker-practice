[TOP](../README.md)   
前: [イメージレジストリ](./image-registry.md)  
次: [まとめ](./image-summary.md)  

---


# イメージの作成

コンテナイメージは公開されているものだけでなく自分たちで作ることもできます。イメージの作成は``Dockerfile``というファイルに作りたいイメージの命令を記述します。このDockerfileと必要な資材を使いコンテナイメージを作成します。

1. イメージビルド用のディレクトリを作成してカレントを移動してください。

2. 以下のコマンドを実行してDockerfileを作成してください。
   ``` sh
   cat <<EOF > Dockerfile
   FROM nginx:1.19.2
   EOF
   ```

3. 以下のコマンドを実行してindex.htmlを作成してください。
   ``` sh
   cat <<EOF > index.html
   container image ni umekomaremsita. 
   EOF
   ```

4. 以下を満たす様にDockerfileを修正してください。
   - 作成した``index.html``を``/usr/share/nginx/html/``配下にコピーしてください。（ヒント：[COPY](https://docs.docker.jp/engine/reference/builder.html#copy)命令を使います。）
   - 環境変数に``ENV=dev``を設定してください。(ヒント：[ENV](https://docs.docker.jp/engine/reference/builder.html#env)命令を使います。)
   - ``["sh","-c","echo $ENV >> /usr/share/nginx/html/index.html"]``コマンドを実行してindex.htmlを編集してください。(ヒント：[RUN](https://docs.docker.jp/engine/reference/builder.html#run)命令を使います。)

5. イメージをビルドしてください。イメージ名は``buildtest:v1``にしてください。（ヒント：ビルドは[docker build](https://docs.docker.jp/engine/reference/commandline/build.html)コマンドを使います。）

6. ホストOSのイメージ一覧を表示し、``buildtest:v1``イメージがあることを確認してください。

7. ``buildtest:v1``イメージのコンテナをバックグランドで実行してください。ホストOSの``8080``をコンテナの``80``に繋いでください。

8. ホストOSからコンテナにcurlを実行してください。以下のメッセージが出るはずです。
   ``` sh
   container image ni umekomaremsita. 
   dev
   ```

9. 以下コマンドでコンテナをすべて削除してください。
    ``` sh
    docker rm -f `docker ps -a -q`
    ```

10. ホストOSのイメージビルド用ディレクトリを削除してください。

このようにしてイメージを作成します。DockerfileのFROMで指定したイメージがベースイメージとなり、そのベースイメージに対してDockerfileで記述した命令を追加で実行しています。ベースイメージは[Dockerオフィシャルのイメージ](https://hub.docker.com/search?type=image&image_filter=official)など、信頼できる提供元のイメージを使用してください。ベースイメージは今回``nginx``を指定しましたが目的に合わせてベースを変更してください。

Dockerfileに書いた内容はコンテナイメージに埋め込まれます。たとえば、上記の例だとDockerfileの中でENV=devを設定し、そのENVでindex.htmlを追記しています。なのでコンテナ起動時に``-e ENV=prod``で環境変数を変えてもindex.htmlの内容はdevのままとなります。（今回の例のようにDockerfileでENVの値を使ってファイルを書き換えるなどは本当は良くありません。真似しないようにしましょう。）

なお、Dockerfileの書き方により作られるコンテナイメージの容量が変わってきます。コンテナイメージの容量は少ないほど開発・運用効率が良いため、いかに軽量のイメージ作るかはエンジニアの腕の見せ所です。てっとり早くイメージを軽量化させるコツとしては[alpine](https://hub.docker.com/_/alpine)など元から軽量なイメージをベースとして使用することです。セキュリティの観点からも余計なものが入っていない軽量イメージは良いとされます。（ただし、軽量イメージはデバック用のコマンドなども入っていなかったりするので注意してください。）

---

[TOP](../README.md)   
前: [イメージレジストリ](./image-registry.md)  
次: [まとめ](./image-summary.md)  
