[TOP](../README.md)   
前: [一時的であるということ](./container-feature-ephemeral.md)  
次: [コンテナへのアクセス](./container-access.md)  

---

# どこでも同じものが動くということ

コンテナはコンテナイメージを使って起動します。同じコンテナイメージを使えばどこでも同じものを動かすことができます。

1. 以下コマンドでディレクトリを作成し移動してください。
   ``` sh
   mkdir test-container
   cd test-container
   ```

2. 以下のコマンドを実行してファイルを作成してください。これはDockerfileというファイルを作成しています。Dockerfileはコンテナイメージを作成するレシピの様なものです。今回はnginxのイメージをベースにindex.htmlの内容を任意の文字列に修正しています。Dockerfileについては後ほどまた触れるのでとりあえずコピペしてください。
   ``` sh
   cat << EOF > Dockerfile
   FROM nginx:1.19.2
   RUN echo "onaji container image de kidou sita container ha nakami mo onaji desu" > /usr/share/nginx/html/index.html
   EOF
   ```

3. Dockerfileからコンテナイメージを作成します。
   ``` sh
   sudo docker build -t nginx:reproducibility .
   ```

4. イメージが作成されたことを確認します。
   ``` sh
   sudo docker images | grep reproducibility
   ```

5. 作成したイメージを使ってコンテナを3つ作ります。
   ``` sh
   sudo docker run -d nginx:reproducibility
   sudo docker run -d nginx:reproducibility
   sudo docker run -d nginx:reproducibility
   ```

6. コンテナが動いていることを確認しつつコンテナIDを確認します。
   ``` sh
   sudo docker ps
   ```

7. コンテナに追加コマンドを発行します。すべてのコンテナで出力結果が同じであることを確認します。
   ``` sh
   sudo docker exec {1つ目CONTAINER ID} sh -c "curl -s localhost"
   sudo docker exec {2つ目CONTAINER ID} sh -c "curl -s localhost"
   sudo docker exec {3つ目CONTAINER ID} sh -c "curl -s localhost"
   ```

8. コンテナをすべて削除します。
   ``` sh
   sudo docker rm -f `sudo docker ps -a -q`
   ```

9. 確認用に作成したコンテナイメージを削除します。
   ``` sh
   sudo docker rmi nginx:reproducibility
   ```

10. 作業したディレクトリも削除します。
   ``` sh
   cd ../
   rm -rf test-container 
   ```

このように、同じコンテナイメージのコンテナは同じものが動きます。つまり、コンテナイメージが共有できれば目的のコンテナをどこででも動かすことができます。（必要なリソースがないなどイメージがあってもコンテナを動かせないこともありますので絶対ではありません。）しかし、動かすプロセスは同じでもたとえば環境ごとにDBの接続情報が異なる場合など、コンテナごとに違いを表現したいことも多々あります。その様な場合、使用するコンテナイメージは一緒でもコンテナ起動時に環境変数を設定したり、コンテナ外のボリュームをマウントさせたりといった方法で差異を表現します。

---

[TOP](../README.md)   
前: [一時的であるということ](./container-feature-ephemeral.md)  
次: [コンテナへのアクセス](./container-access.md)  
