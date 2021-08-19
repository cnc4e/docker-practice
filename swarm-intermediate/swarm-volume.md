[TOP](../README.md)   
前: [シークレットの使用](./swarm-secret.md)  
次: -  

---

`このプラクティスはAWS環境を前提にしています。`

またこのプラクティスで使用する Amazon EFSを作成するterraformコードを用意しています。
[環境構築用Terraform（EFS）](../terraform/guide.md#efs)を参照してください。

# ボリュームの使用

コンテナの外部にデータを保管する方法として、`volumeマウント`と`bindマウント`の2つがあります。`volumeマウント`はボリュームプラグインとDockerが連携することで専用のボリュームを切り出し、そのボリュームをタスクにマウントさせる方法です。`bindマウント`はあらかじめノードにマウント対象のパスを作成する必要がありますが、`volumeマウント`ではその必要はありません。ノード数が大量にあり、マウントするボリュームの数も多い場合はbindマウントよりもvolumeマウントの方が楽に管理できるでしょう。（[ネタ元](https://docs.docker.com/storage/volumes/)）

ボリュームプラグインはさまざまなものが提供されています。一覧は[こちら](https://docs.docker.com/engine/extend/legacy_plugins/#volume-plugins)を参照してください。

本プラクティスはプラグインとして[Netshare plugin](http://netshare.containx.io/)を使用し、Amazon EFSをvolumeマウントします。（Netshare pluginはEFSでなくてもNFSなら使えるんだと思う。）

## プラグインの準備

1. ワーカーノードと同じVPCにEFSを構築してください。また、EFSのSGにはワーカーノードからのインバウンドアクセスを許可したルールを設定してください。作成したEFSのIPアドレスを控えておいてください。

2. **すべてのワーカーノードで**[こちら](https://github.com/ContainX/docker-volume-netshare/releases)からワーカーノードの種類にあったバイナリをワーカーノードにダウンロードしてください。以下、コマンド例です。

``` sh
wget https://github.com/ContainX/docker-volume-netshare/releases/download/v0.36/docker-volume-netshare_0.36_linux_amd64.tar.gz
```

3. **すべてのワーカーノードで**上記ダウンロードしたバイナリを展開し`docker-volume-netshare`をパスの通るディレクトリに配置してください。配置したら`docker-volume-netshare`が使用できることを確認してください。以下例です。

``` sh
tar -zxvf docker-volume-netshare_0.36_linux_amd64.tar.gz
mv docker-volume-netshare_0.36_linux_amd64/docker-volume-netshare /usr/local/sbin/
docker-volume-netshare -h
```

4. **すべてのワーカーノードで**`docker-volume-netshare`をバックグランドで実行します。ターミナルセッションは残しおきます。このあとの複数の手順でワーカーノードの操作が発生します。

``` sh
docker-volume-netshare efs --noresolve &
```

## volumeマウントの実践

1. 以下満たすcomposeファイル`volume-mount.yaml`を作成してください。（[ヒント①](https://docs.docker.com/compose/compose-file/compose-file-v3/#volume-configuration-reference)、[ヒント②](https://www.it-swarm-ja.com/ja/docker/docker-compose-v3%E3%82%92%E4%BD%BF%E7%94%A8%E3%81%97%E3%81%A6%E3%82%B3%E3%83%B3%E3%83%86%E3%83%8A%E3%81%ABnfs%E5%85%B1%E6%9C%89%E3%83%9C%E3%83%AA%E3%83%A5%E3%83%BC%E3%83%A0%E3%82%92%E7%9B%B4%E6%8E%A5%E3%83%9E%E3%82%A6%E3%83%B3%E3%83%88%E3%81%99%E3%82%8B%E6%96%B9%E6%B3%95/833008956/)）
`※volumeの設定を変更する場合、再deployしても変更が反映されません。一度 docker volume rm でvolumeを削除してから再deployしてください。`

- service名: service
  - image: nginx
  - replicas: 2
  - volumes: efsを/dataにマウント
- volume名: efs
  - driver: local
  - driver_opts: typeはnfs、、nfsのバージョンは4を指定、アドレスでEFSのIPアドレスを指定
  - device: ":/"

2. 上記作成したcomposeファイルを指定し、スタック`test`を作成してください。

3. スタックの一覧、スタック内のサービス一覧、スタック内のタスク一覧をそれぞれ表示し、タスクが2つデプロイされていることを確認してください。また、タスクを実行しているノードが分散していることも確認してください。

4. **どちらか一方のワーカーノードにて**スタック`test`でデプロイしたコンテナ内を確認し/dataがあることを確認してください。また、/data以下にファイルを作成してください。

``` sh
docker exec <container id> ls -l /data
docker exec <container id> touch /data/test-file
```

5. **もう一方のワーカーノードにて**スタック`test`でデプロイしたコンテナ内を確認し/data以下に別コンテナで作成したファイルがあることを確認してください。

``` sh
docker exec <container id> ls /data
```

6. **両方のワーカーノードにて**Dockerボリュームの一覧を表示してください。ボリューム`test_efs`が作成されていることを確認してください。（[ヒント](https://docs.docker.com/engine/reference/commandline/volume_ls/)）

7. スタック`test`を削除してください。

8. **両方のワーカーノードにて**Dockerボリュームの一覧を表示してください。ボリューム`test_efs`が残っていることを確認してください。

9. スタック`test`を再作成してください。

10. スタックの一覧、スタック内のサービス一覧、スタック内のタスク一覧をそれぞれ表示し、タスクが2つデプロイされていることを確認してください。また、タスクを実行しているノードが分散していることも確認してください。

11. **両方のワーカーノードにて**スタック`test`でデプロイしたコンテナ内を確認し/data以下のデータが残っていることを確認してください。

``` sh
docker exec <container id> ls /data
```

12. スタック`test`を削除してください。

## 後片付け

1. **すべてのワーカーノードで**dockerボリューム`test_efs`を削除してください。（[ヒント](https://docs.docker.com/engine/reference/commandline/volume_rm/)）

2. **すべてのワーカーノードで**バックグラウンド実行していた`docker-volume-netshare`を停止してください。

3. EFSを削除してください。

*[解答例](./.ans/swarm-volume.md)*

---

[TOP](../README.md)   
前: [シークレットの使用](./swarm-secret.md)  
次: -  