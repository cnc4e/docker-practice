[TOP](../README.md)   
前: [セキュリティ](./swarm-security.md)  
次: -  

---

# バックアップ

バックアップが必要なデータは主に以下です。

1. Swarmクラスタの状態
2. マウントする外部ボリューム
3. コンテナレジストリのデータ
4. composeファイル

この内、2については通常のファイルバックアップやボリュームバックアップの仕組みでバックアップしてください。3はレジストリサービスの機能などでバックアップしてください。4はGitレポジトリで管理するなどしてください。

1のSwarmクラスタの状態はどのような情報でしょうか？これには現在クラスタにデプロイされているサービスやネットワーク、コンフィグなどの情報です。サービスなどは基本的にcomposeファイルを使い再デプロイすることでも復元可能です。ですが、composeファイルに残していないデータ（たとえばシークレットとかコマンドでデプロイしたタスクとか）は消えてしまうと復元できません。そのため、万が一に備えてクラスタの状態をバックアップしても良いでしょう。

バックアップおよびリストアの方法をみていきます。なお、手順はこちらの[バックアップ手順](https://docs.docker.com/engine/swarm/admin_guide/#back-up-the-swarm)と[リストア手順](https://docs.docker.com/engine/swarm/admin_guide/#restore-from-a-backup)を参考にしています。

## クラスタ状態のバックアップ・リストア

1. 以下コマンドでindex.htmlを作成してください。（内容はなんでも良いです。）

``` sh
echo backup data > index.html
```

2. 以下満たすcomposeファイル`backup.yaml`を作成してください。

- service名: backup
  - image: nginx
  - deploy mode: replicated
  - replicas: 1
  - configs: indexを/usr/share/nginx/html/index.htmlにマウント
- config名: index
  - file: ./index.html

3. 上記作成したcomposeファイルを指定し、スタック`test`を作成してください。

4. スタックの一覧、スタック内のサービス一覧、スタック内のタスク一覧をそれぞれ表示してください。タスクがデプロイされていることを確認してください。

5. コンフィグの一覧を表示してください。コンフィグがデプロイされていることを確認してください。

5. **タスクを実行しているノード** コンテナに対し追加コマンドを発行し、loaclhostに対してcurlしてください。indexの内容が表示されることを確認してください。

ここまでが準備です。ではこれからバックアップを取得します。

6. **すべてのマネージャ** /var/lib/dockerディレクトリ以下にswarmディレクトリがあることを確認してください。

7. **すべてのマネージャ** dokcerサービスを停止してください。

8. **すべてのマネージャ** /var/lib/docker/swarmディレクトリを適当な場所にコピーしてください。たとえば以下です。

``` sh
cp -r /var/lib/docker/swarm /var/lib/docker/swarm-bk
```

9. **すべてのマネージャ** dokcerサービスを開始してください。

以上がバックアップです。/var/lib/docker/swarmディレクトリ内にクラスタの情報が保存されているため、このディレクトリをまるごとバックアップすれば良いです。なお、docker起動中にディレクトリコピーすることも可能ですが推奨されません。[ネタ元](https://docs.docker.com/engine/swarm/admin_guide/#back-up-the-swarm)

つづいて擬似的な障害としてスタックを削除します。

10.  スタック`test`を削除してください。

11.  スタックの一覧を表示し、`test`が消えていることを確認してください。

ではクラスタ状態をリストアしスタック`test`を復活させます。

12. **すべてのマネージャ** dokcerサービスを停止してください。

13. **すべてのマネージャ** /var/lib/docker/swarmディレクトリを削除してください。（必ず消してください。）

14. **すべてのマネージャ** バックアップしたデータから/var/lib/docker/swarmディレクトリをリストアしてください。たとえば以下コマンドです。

``` sh
cp -r /var/lib/docker/swarm-bk /var/lib/docker/swarm
```

15. **すべてのマネージャ** /var/lib/dockerディレクトリ以下にswarmディレクトリがあることを確認してください。

16. **すべてのマネージャ** dokcerサービスを開始してください。

以上でリストア完了です。確認します。

17. スタックの一覧、スタック内のサービス一覧、スタック内のタスク一覧をそれぞれ表示してください。タスクがデプロイされていることを確認してください。

18. コンフィグの一覧を表示してください。コンフィグがデプロイされていることを確認してください。

19. **タスクを実行しているノード** コンテナに対し追加コマンドを発行し、loaclhostに対してcurlしてください。indexの内容が表示されることを確認してください。

20. スタック`test`を削除してください。

> **一台だけリストアした場合はどうなりますか？**  
> managerの内もっとも日付の新しい状態になります。そのため、一台だけリストアしても他のmanagerが持つ最新の状態となってしまうため意味がありません。リストアする時は必ずすべてのマネージャをリストアしましょう。

> **ノードのスナップショットなどで代用しても良いですか？**  
> 良いと思います。ただし、必ずスナップショットはすべてのmanagerに対して同じ静止断面で取ってください。また、リストアするときはすべてのmanagerをリストアしてください。

*[解答例](./.ans/swarm-backup.md)*

---

[TOP](../README.md)   
前: [セキュリティ](./swarm-security.md)  
次: -  