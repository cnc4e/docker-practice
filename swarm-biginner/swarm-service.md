[TOP](../README.md)   
前: [Swarmクラスタの構築](./swarm-create.md)  
次: [サービスの配置](./swarm-service-placement.md)  

---

# サービスの作成

Swarmでは`サービス`という単位でデプロイを行います。`サービス`は`タスク`の集まりです。`タスク`とはコンテナのことです。Swarmはサービスの状態を常に定義した状態を保つように動作します。まずは簡単なサービスを起動し、サービスおよびタスクがどういうものか触れていきます。

## コマンドによるサービス起動

まずはコマンドでサービスを起動してみます。いずれかのマネージャに接続して以下を実施してください。マネージャ以外で操作する場合は明示的に実行場所を記載します。

1. `docker service create`コマンドを使って`test`という名前のサービスを作成してください。イメージは`nginx`を使用してください。（[ヒント](https://docs.docker.com/engine/reference/commandline/service_create/#create-a-service)）

2. サービスの一覧を表示し`test`という名前のサービスが作成されていることを確認してください。（[ヒント](https://docs.docker.com/engine/reference/commandline/service_ls/)）

3. サービス`test`の中のタスク一覧を表示してください。また、タスクが実行されているノードを確認してください。（[ヒント](https://docs.docker.com/engine/reference/commandline/service_ps/)）

4. **タスクが実行されているノード**にログインしてください。

5. **タスクが実行されているノード**でコンテナの一覧を表示してください。

6. **タスクが実行されているノード**をrebootしてください。

7. サービス`test`の中のタスク一覧を表示してください。タスクが新たに作成されていることを確認してください。また、タスクが実行されているノードを確認してください。スケジュールされているノードが変わっているはずです。

8. サービス`test`のタスク数を3に増やしてください。（[ヒント](https://docs.docker.com/engine/reference/commandline/service_scale/)）

9. サービスの一覧を表示し`test`という名前のサービスのレプリカ数が3になっていることを確認してください。

10. サービス`test`の中のタスク一覧を表示してください。Runningのタスクが3つあることを確認してください。また、タスクが実行されているノードが分散されていることを確認してください。

11. サービス`test`を削除してください。（[ヒント](https://docs.docker.com/engine/reference/commandline/service_rm/)）

12. サービスの一覧、タスクの一覧を表示しすべて消えていることを確認してください。

このようにSwarmを使用すると複数ノードにまたがるコンテナの分散配置ができます。また、サービスで指定したコンテナ数を常に維持するように動くため、たとえばノード障害などが発生すると別のノードでコンテナを作成し直してくれます。(Swarmでない場合、ノードをまたいだコンテナ作成まではしてくれません。)

## composeによるサービス起動

Swarmでもdocker-composeを使うことができます。サービスの設定は多いためコマンドでの作成、管理は大変です。基本的にcomposeを使って作成、管理するようにしましょう。さきほどコマンドで作成したサービスをcomposeで同じ様に作成します。

1. マネージャの任意のディレクトリ配下で`service`ディレクトリを作成します。

2. `service`ディレクトリ配下で以下内容の`test.yaml`を作成します。なお、Swarmの場合バージョンは必ず3.X以上を指定します。

``` yaml
version: "3.9"

services:
  test:
    image: nginx
    deploy:
      replicas: 1
```

1. `service`ディレクトリにて`docker stack deploy`コマンドで上記作成したcomposeファイルを指定したサービスのデプロイを行います。スタック名は`test`を指定します。（[ヒント](https://docs.docker.com/engine/reference/commandline/stack_deploy/)）

2. スタックの一覧を表示し、`test`という名前のスタックがあることを確認してください。（[ヒント](https://docs.docker.com/engine/reference/commandline/stack_ls/)）

3. スタック`test`に含まれるサービスの一覧を表示してください。（[ヒント](https://docs.docker.com/engine/reference/commandline/stack_services/)）

4. スタック`test`に含まれるタスクの一覧を表示してください。（[ヒント](https://docs.docker.com/engine/reference/commandline/stack_ps/)）

5. `test.yaml`を修正しreplicasを3にしてください。

6. `docker stack deploy`コマンドで再度スタックをデプロイしてください。（削除はしなくてもデプロイすれば上書きされます。）

7. スタック`test`に含まれるサービスとタスクを表示してください。タスク数が3に増えていることを確認してください。

8.  スタック`test`を削除してください。（[ヒント](https://docs.docker.com/engine/reference/commandline/stack_rm/)）

9.  スタックの一覧を表示し、スタック`test`が削除されていることを確認してください。

以上の通り、composeフィアルを使ってサービスをデプロイできます。`スタック`は複数のサービスをまとめたものです。docker-composeにおけるプロジェクトと同じようなものです。サービスの設定は多岐に渡るためコマンドでの管理は難しいです。そのため、本プラクティスではcomposeファイルに記述する前提で進めていきます。

なお、composeファイルの管理には注意が必要です。あるマネージャノードにだけ保存しているとそのマネージャノード障害時にcomposeファイルが使えなくなってしまいます。そのため、composeファイルの管理はGitや共有ファイルシステムなど、すべてのマネージャノードで共有できる仕組みを採用しましょう。

---

[TOP](../README.md)   
前: [Swarmクラスタの構築](./swarm-create.md)  
次: [サービスの配置](./swarm-service-placement.md)  