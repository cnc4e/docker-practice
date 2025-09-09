[TOP](../README.md)   
前: [コンテナへのアクセス](./container-access.md)  
次: [コンテナに環境変数を設定](./container-env.md)  

---

# コンテナにファイルシステムをマウント

コンテナ内のファイルシステムは一時的な領域です。コンテナが無くなるとコンテナ内のファイルシステムに保存したデータも失われてしまいます。これを回避するにはコンテナに外部のボリュームをマウントしデータをその中に保存します。

1. ``centos:8``のイメージを使いコンテナをバックグラウンドで実行してください。なお、centosのイメージはコマンドを指定しないとすぐに停止するので``sh -c "sleep 3600"``などのコマンドを指定して実行してください。

2. 作成したコンテナにログインし、適当な場所にテストファイルを作成してください。

3. コンテナを削除してください。

4. 先ほどの手順と同じく``centos:8``のイメージを使いコンテナをバックグランドで実行してください。

5. 先ほど作成したテストファイルがなくなっていることを確認してください。

6. コンテナを削除してください。

このように、コンテナに変更を加えてもそのコンテナが失われるとデータも一緒に消えてしまいます。（なお、コンテナを``削除``ではなく``停止``すればテスト用のデータは消えませんが、コンテナを停止するという運用はあまり行わず起動/削除が一般的です。）

それでは、コンテナにボリュームをマウントさせてデータを保存してみます。

7. ホストOSに``~/host-dir``というテスト用のディレクトリを作成してください。

8. ``centos:8``のイメージを使いコンテナをバックグラウンドで実行してください。この時、先ほど作成したホストOSのテスト用ディレクトリをコンテナ内の``/container-dir``にマウントしてください。ボリュームマウントは``docker runコマンドのオプション``で指定します。やり方は[日本語マニュアル](http://docs.docker.jp/engine/tutorials/dockervolumes.html#mount-a-host-directory-as-a-data-volume)を参考にしてください。

9.  作成したコンテナにログインし``/container-dir``があることを確認してください。

10. コンテナ内の``/container-dir``配下にテスト用ファイルを作成してください。

11. コンテナを削除してください。

12. 先ほどの手順と同じく``centos:8``のイメージを使いコンテナをバックグラウンドで実行してください。この時、ホストOSのテスト用ディレクトリをコンテナ内の``/container-dir``にマウントしてください。

13. コンテナにログインし/container-dir配下のテスト用ファイルが``あること``を確認してください。

14. ホストOSの``~/host-dir``配下を確認してください。コンテナ内で作成したファイルがあるはずです。

15. ホストOSから``~/host-dir``配下のテストファイルを削除してください。

16. コンテナにログインし、/container-dir配下のテスト用ファイルが``ないこと``を確認してください。

17. 以下コマンドでコンテナをすべて削除してください。
    ``` sh
    docker rm -f `docker ps -a -q`
    ```

18. ホストOSの``~/host-dir``ディレクトリを削除してください。

このように、コンテナにボリュームをマウントさせればデータをコンテナのライフサイクルと切り離すことができます。

<details>
<summary>
答え(一例です)
</summary>

1. 以下コマンドを実行する。
```
docker run -d centos:8 sh -c "sleep 3600"
```

2. 以下コマンドを実行する。
```
$ docker ps
CONTAINER ID   IMAGE      COMMAND                CREATED          STATUS          PORTS     NAMES
b47f4cbe7663   centos:8   "sh -c 'sleep 3600'"   44 seconds ago   Up 40 seconds             elastic_davinci
$ docker exec -it {docker psで確認したコンテナID} bash
# touch test.txt
```

3. 以下コマンドを実行する。
```
$ docker rm -f {docker psで確認したコンテナID}
{docker psで確認したコンテナID}
```

4. 1.と同じコマンドを実行する。
5. 以下コマンドの手順で確認する。
```
$ docker ps
CONTAINER ID   IMAGE      COMMAND                CREATED         STATUS         PORTS     NAMES
2c2d5243c77b   centos:8   "sh -c 'sleep 3600'"   7 seconds ago   Up 5 seconds             vibrant_bassi
$ docker exec -it {docker psで確認したコンテナID} bash
# ls
bin  dev  etc  home  lib  lib64  lost+found  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
```

6. 3.と同じコマンドを実行する。
7. 以下コマンドを実行する。
```
mkdir ~/host-dir
```

8. 以下コマンドを実行する。ここで、`-v`コマンドはイメージよりも前で記述することに注意してください。
```
docker run -d -v ~/host-dir:/container-dir centos:8 sh -c "sleep 3600"
```

9. 以下コマンドの手順で確認する。
```
$ docker ps
CONTAINER ID   IMAGE      COMMAND                CREATED         STATUS         PORTS     NAMES
83b2395f89b1   centos:8   "sh -c 'sleep 3600'"   4 seconds ago   Up 3 seconds             charming_noether
$ docker exec -it {docker psで確認したコンテナID} bash
# ls
bin  container-dir  dev  etc  home  lib  lib64  lost+found  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
```

10. 以下コマンドを実行する。
```
# cd container-dir/
# touch test.txt
```

11. 3.と同じコマンドを実行する。
12. 8.と同じコマンドを実行する。
13. 以下コマンドの手順で確認する。
```
$ docker ps
CONTAINER ID   IMAGE      COMMAND                CREATED          STATUS          PORTS     NAMES
30bbdf7e1ed7   centos:8   "sh -c 'sleep 3600'"   44 seconds ago   Up 43 seconds             hopeful_roentgen
$ docker exec -it {docker psで確認したコンテナID} bash
# ls container-dir/
test.txt
```

14. 以下コマンドの手順で確認する。
```
# exit
exit
$ ls ~/host-dir/
test.txt
```

15. 以下コマンドを実行する。
```
$ rm -f ~/host-dir/test.txt
```

16. 以下コマンドの手順で確認する。
```
$ docker exec -it 30bbdf7e1ed7 bash
# ls container-dir/
# 
```

17. `exit`でコンテナから出た後、プラクティスの指示コマンドを実行してください。
18. 以下コマンドを実行する。
```
$ rm -rf ~/host-dir/
```

</details>

---

[TOP](../README.md)   
前: [コンテナへのアクセス](./container-access.md)  
次: [コンテナに環境変数を設定](./container-env.md)  
