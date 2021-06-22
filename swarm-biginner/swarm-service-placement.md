[TOP](../README.md)   
前: [サービスの作成](./swarm-service.md)  
次: [サービスのリソース指定](./swarm-service-resouces.md)  

---

# サービスの配置

サービスのタイプは2種類あります。`replicated`と`global`です。（[ネタ元](https://docs.docker.com/engine/swarm/services/#control-service-placement)）

`replicated`は基本のサービスタイプです。タスクのレプリカ数を指定し、常にそのレプリカ数のタスクが動くようになります。通常ワークロード用のコンテナを起動したい場合はこのサービスタイプを使います。

`global`は少し異なります。すべてのノード上にタスクを展開するようになります。新しいワーカーノードをクラスタに追加した時、自動で追加ノードでもタスクが実行されます。クラスタを管理する機能（ログやメトリクス監視など）を実装する際にこのサービスタイプを使います。

## replicated

1. 以下満たすcomposeファイル`service-placement-replica.yaml`を作成してください。（[ヒント](https://docs.docker.com/compose/compose-file/compose-file-v3/#mode)）

- service名: test
- image: nginx
- deploy mode: replicated
- replicas: 1

2. 上記作成したcomposeファイルを指定し、スタック`test`を作成してください。

3. スタックの一覧、スタック内のサービス一覧、スタック内のタスク一覧をそれぞれ表示し、タスクが1つデプロイされていることを確認してください。

4. スタック`test`を削除してください。

replicatedはデフォルトのモードなので`mode: replicated`は省略可能です。多分、そっちの書き方の方が一般的と思われます。また、`replica: 1`も省略するとデフォルトで1になります。ただレプリカ数は将来増やすかもしれないので1の場合でも記述した方が無難です。

replicatedによりタスクがスケジュールされるノードはマネージャにより選定されます。選定はまずCPU/メモリのリソースの要求値を確保できるノード群が選ばれます。（リソース要求については[別の章](./swarm-service-resouces.md)を設けて解説します。）　さらに`constraint`と`preferences`でより細かくスケジュールノードを指定できます。（[ネタ元](https://docs.docker.com/engine/swarm/services/#control-service-placement)）

**constraint**はタスクをスケジュールするノードを指定する設定です。この判別にはノードに付与されたラベルを使います。指定したkey=valueのラベルが付与されたノードにタスクがスケジュールされます。または`!=`を使用するとスケジュールを避けることができます。また、いずれのノードにしも指定したKey=vlueのラベルがない場合、タスクはどのノードにもスケジュールされません。（[ネタ元](https://docs.docker.com/engine/swarm/services/#placement-constraints)）

**preferences**はconstraintよりもゆるいノード指定です。判別にはノードに付与されたラベルを使います。指定したkeyのラベルが付与されたノードにタスクがスケジュールされます。また、いずれのノードにしも指定したKeyのラベルがない場合、preferencesを指定しなかったかのようにスケジュールされます。

### ノードにラベル付与

1. 各ワーカーノードに`name=<worker0 or 1>`のラベルを付与してください。（[ヒント](https://docs.docker.com/engine/reference/commandline/node_update/)）

2. ノードにラベルが付与されていることを確認してください。（[ヒント](https://docs.docker.com/engine/reference/commandline/node_inspect/)）

### constraint

1. 以下を満たすcomposeファイル`service-placement-constraint.yaml`を作成してください。（[ヒント](https://docs.docker.com/compose/compose-file/compose-file-v3/#placement)）

- service名: test
- image: nginx
- replicas: 2
- constraint: name=worker0 のラベルを指定 ([ヒント](https://docs.docker.com/engine/swarm/services/#placement-constraints)) 

2. 上記作成したcomposeファイルを指定し、スタック`test`を作成してください。

3. スタックの一覧、スタック内のサービス一覧、スタック内のタスク一覧をそれぞれ表示し、タスクが2つデプロイされていることを確認してください。また、スケジュールされたノードが同じであることも確認してください。

4. スタック`test`を削除してください。

5. composeファイルを以下のように修正してください。

- constraint: name=hoge のラベルを指定

6. スタックの一覧、スタック内のサービス一覧、スタック内のタスク一覧をそれぞれ表示し、タスクが2つデプロイされていることを確認してください。また、タスクのCURRENT STATEがPendingになっており、どのノードにもスケジュールされていないことを確認してください。

7. スタック`test`を削除してください。

### preferences

1. 以下を満たすcomposeファイル`service-placement-pref.yaml`を作成してください。（[ヒント](https://docs.docker.com/compose/compose-file/compose-file-v3/#placement)）

- service名: test
- image: nginx
- replicas: 2
- preferences: key:name のラベルを指定 ([ヒント](https://docs.docker.com/engine/swarm/services/#placement-preferences)) 

2. 上記作成したcomposeファイルを指定し、スタック`test`を作成してください。

3. スタックの一覧、スタック内のサービス一覧、スタック内のタスク一覧をそれぞれ表示し、タスクが2つデプロイされていることを確認してください。また、スケジュールされたノードが分散されていることも確認してください。

4. スタック`test`を削除してください。

5. composeファイルを以下のように修正してください。

- preferences: key:hoge のラベルを指定

6. スタックの一覧、スタック内のサービス一覧、スタック内のタスク一覧をそれぞれ表示し、タスクが2つデプロイされていることを確認してください。また、スケジュールされたノードが分散されていることも確認してください。（constraintとは違い、条件に一致しなくてもタスクをスケジュールします。）

7. スタック`test`を削除してください。

（正直、preferenceの使い所がよくわかっていない。。。できればこのノードで上がってほしいなくらいの緩い縛りなのかと。）

## global

1. 以下満たすcomposeファイル`service-placement-global.yaml`を作成してください。（[ヒント](https://docs.docker.com/compose/compose-file/compose-file-v3/#mode)）

- service名: test
- image: nginx
- deploy mode: global

2. 上記作成したcomposeファイルを指定し、スタック`test`を作成してください。

3. スタックの一覧、スタック内のサービス一覧、スタック内のタスク一覧をそれぞれ表示し、タスクがすべてのワーカーノードに1つずつデプロイされていることを確認してください。

4. スタック`test`を削除してください。

---

[TOP](../README.md)   
前: [サービスの作成](./swarm-service.md)  
次: [サービスのリソース指定](./swarm-service-resouces.md)  