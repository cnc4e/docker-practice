[TOP](../README.md)   
前: [まとめ](./image-summary.md)  
次: -  

---

# イメージの手動運搬

コンテナイメージはイメージレジストリで共有するのが望ましいです。ですが、開発と本番などネットワーク的に分離する必要がある場合もあります。その様な場合、イメージをtarに固めてファイルとして送ることもできます。

1. ホストOS内部にあるコンテナイメージを確認し、その内の1つを``manual-transport``というイメージ名にしてください。この時選ぶイメージはできれば転送先のもう1台のサーバにないイメージが良いです。

2. 以下のコマンドでイメージをtarにしてください。
   ``` sh
   docker save -o manual-transport.tar manual-transport
   ```

3. カレントディレクトリに``manual-transport.tar``があることを確認してください。

4. ``manual-transport.tar``をもう1台のサーバにscpなどで転送してください。

ここからはもう1台のサーバで作業します。

5. ``manual-transport``という名前のイメージがないことを確認してください。

6. 以下コマンドで``manual-transport.tar``をインポートします。
   ``` sh
   docker load -i manual-transport.tar
   ```

7. ``manual-transport``という名前のイメージがあることを確認してください。また、``manual-transport``の``IMAGE ID``が2台のサーバで一致していることを確認してください。

ここからは両方のサーバで同じ作業します。

8. ``manual-transport``イメージを削除してください。

9. ``manual-transport.tar``を削除してください。

このようにしてイメージを手動で運搬することもできます。運搬したあとはその環境のレジストリサーバ名などのイメージ名にタグ打ちし直してpushすれば環境内で共有できます。なお、イメージの``IMAGE ID``はイメージのハッシュ値が使われています。そのため、ハッシュ値を見ればイメージ名が違くてもイメージの中身が同じか判別できます。

<details>
<summary>
答え(一例です)
</summary>

1. 以下コマンドを実行する。
```
$ docker images
REPOSITORY                                                      TAG               IMAGE ID       CREATED        SIZE
centos                                                          8                 5d0da3dc9764   4 years ago    231MB
$ docker tag {元イメージ} manual-transport
```

2. プラクティスの指示コマンドを実行してください。
3. 以下コマンドを実行して確認してください。
```
$ ls
manual-transport.tar
```

4. 以下コマンドを実行する。
```
$ scp -i {秘密鍵までのパス} manual-transport.tar {転送先のユーザー名}@{転送先サーバのホスト名}:~/
manual-transport.tar                                                                                      100%  228MB 127.5MB/s   00:01
```

5. 以下コマンドを実行する。
```
$ docker images
REPOSITORY   TAG       IMAGE ID   CREATED   SIZE
```

6. プラクティスの指示コマンドを実行してください。
7. 以下コマンドを両サーバで実行して確認してください。
```
$ docker images
REPOSITORY                                                      TAG               IMAGE ID       CREATED        SIZE
manual-transport                                                latest            5d0da3dc9764   4 years ago    231MB

$ docker images
REPOSITORY         TAG       IMAGE ID       CREATED       SIZE
manual-transport   latest    5d0da3dc9764   4 years ago   231MB
```

8. 以下コマンドを両サーバで実行する。
```
docker rmi manual-transport
```

9. 以下コマンドを両サーバで実行する。
```
$ rm manual-transport.tar
```

</details>

---

[TOP](../README.md)   
前: [まとめ](./image-summary.md)  
次: -  
