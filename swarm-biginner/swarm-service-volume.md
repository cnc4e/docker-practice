[TOP](../README.md)   
前: [サービスのリソース指定](./swarm-service-resouces.md)  
次: [サービスの外部公開](./swarm-service-expose.md)  

---

# サービスのボリュームマウント

コンテナ内のデータは一時的でコンテナが消えると同時に消えてしまいます。消えては困るデータはコンテナに外部ボリュームをマウントさせ、その中にデータを書き込みます。Swarmではタスクに外部のボリュームをマウントさせる方法が2つあります。`volumeマウント`と`bindマウント`です。

**volumeマウント**はボリュームドライバとDockerが連携することで専用のボリュームを切り出し、そのボリュームをタスクにマウントさせる方法です。（[ネタ元](https://docs.docker.com/storage/volumes/)）

**bindマウント**はホストのファイルシステムをマウントさせる方法です。（[ネタ元](https://docs.docker.com/storage/bind-mounts/)）

**volumeマウント**は別に章を設けて解説します。まずはわかりやすい**bindマウント**を実践してみます。

なお、bindマウントをする場合、あらかじめホストにソースとなるマウントパスを作成しておく必要があります。つまり、すべてのワーカーノードにマウントパスがないとスケジュールされるノードが偏ります。（[ネタ元](https://docs.docker.com/engine/swarm/services/#bind-mounts)）

1. worker0に接続し以下コマンドでテスト用のファイルを作成してください。

``` sh
mkdir /tmp/mount/
echo worker0 > /tmp/mount/test.txt
```

2. worker1に接続し以下コマンドでテスト用のファイルを作成してください。

``` sh
mkdir /tmp/mount/
echo worker1 > /tmp/mount/test.txt
```

3. 以下満たすcomposeファイル`service-bind.yaml`を作成してください。（[ヒント](https://docs.docker.com/compose/compose-file/compose-file-v3/#volumes)）

- service名: test
- image: nginx
- replicas: 2
- volumes: bindタイプでホストの/tmp/mountをコンテナの/tmpにマウント

4. 上記作成したcomposeファイルを指定し、スタック`test`を作成してください。

5. スタックの一覧、スタック内のサービス一覧、スタック内のタスク一覧をそれぞれ表示し、タスクが2つデプロイされていることを確認してください。また、タスクが別々のノードにスケジュールされていることを確認してください。（分散されていなければレプリカ数を増やすなどして分散させてください。）

6. **worker0に接続**し、スタック`test`でデプロイしたコンテナ内の/tmp/test.txtを確認してください。`worker0`と表示されるはずです。

7. **worker0に接続**し、スタック`test`でデプロイしたコンテナ内に/tmp/hogeファイルを作成してください。

8. **worker0に接続**し、スタック`test`でデプロイしたコンテナを強制削除してください。

9. **worker0に接続**し、スタック`test`でデプロイしたコンテナが再作成されていることを確認してください。また、/tmp/hogeファイルが残っていることを確認してください。

10. **worker1に接続**し、スタック`test`でデプロイしたコンテナ内の/tmp/test.txtを確認してください。`worker1`と表示されるはずです。

11. **worker1に接続**し、スタック`test`でデプロイしたコンテナ内に/tmp/hogeファイルがあるか確認してください。無いはずです。

12. スタック`test`を削除してください。

このようにbindマウントだとホストのファイルシステムをコンテナにマウントできます。マウントした領域はコンテナのライフサイクルとは切り離されるためコンテナが消えてもデータを残せます。ここで注意が必要なのはタスクごとにマウントする実ボリュームは異なる点です。上記の例ではworker0のコンテナに書き込んだ/tmp/hogeはworker1のコンテナにはありませんでした。そのため、コンテナ間でデータの共有が必要な場合(例えばwebサーバのキャッシュなど)はホストパスで指定するパスをあらかじめNFS等の共有ボリュームでマウントしておく必要があります。またはvolumeマウントでNFSを直接コンテナがマウントするのも良いでしょう。

（[tmpfs](https://docs.docker.com/storage/tmpfs/)についても触れる？これの使い所がよくわからない。）

---

[TOP](../README.md)   
前: [サービスのリソース指定](./swarm-service-resouces.md)  
次: [サービスの外部公開](./swarm-service-expose.md)  