[TOP](../README.md)   
前: [サービスの配置](./swarm-service-placement.md)  
次: [サービスのボリュームマウント](./swarm-service-volume.md)  

---

# サービスのリソース指定

コンテナはリソース(CPU/memory)の制限を設けないとノードのリソースをあるだけ使おうとします。そのため、コンテナを起動するときは必ずリソース量を指定するようにしましょう。リソース量はサービスごとに設定します。リソース量の指定には2種類あります。`limits`と`reservations`です。

**limits**はコンテナが使用できるリソース量の上限です。コンテナはこの指定よりも多くのリソースを使用しません。

**reservations**はコンテナ起動時に最低限確保されるリソース量です。コンテナがスケジュールされると実際に使用していなくてもその分のリソースが予約されます。もし、どのノードでもリソースが確保できない場合、タスクはPendingとなりどのノードにもスケジュールされません。

1. 以下満たすcomposeファイル`service-resources.yaml`を作成してください。（[ヒント](https://docs.docker.com/compose/compose-file/compose-file-v3/#resources)）

- service名: test
- image: nginx
- replicas: 1
- limit: CPU:0.5コア Memory:500M
- reservations: CPU:0.25コア Memory:250M

2. 上記作成したcomposeファイルを指定し、スタック`test`を作成してください。

3. スタックの一覧、スタック内のサービス一覧、スタック内のタスク一覧をそれぞれ表示し、タスクが1つデプロイされていることを確認してください。

4. サービスの詳細を表示し、limitsとreservationsが設定されていることを確認してください。

5. composeファイルを修正し、replicasを20にしてください。

6. composeファイルを指定し、スタック`test`をアップデートしてください。

7. スタックの一覧、スタック内のサービス一覧、スタック内のタスク一覧をそれぞれ表示し、タスクが20個デプロイされていることを確認してください。また、其内16個はRunningになっており、4個はPendingになっていることを確認してください。（AWSのt2.medium(cpu:2、memory:2G)が2台の場合です。違うスペックのノード、台数だと結果が違うかもしれません。その場合、ノードスペックとreservationに指定した値からタスクがPendingになるrepliasを調整してください。）

8. スタック`test`を削除してください。

このように、reservationsに指定したリソースが確保できないとタスクはPendingになります。limitsの値はオーバーコミット可能なので注意してください。オーバーコミット状態だとノードのリソースが枯渇し、OOM Killやノード停止などに陥る可能性があります。安全にするならlimitsとreservationsの値を同じにすれば良いです。

（今各ノードでどれくらいのHWリソースを予約済かとか見る方法がわからない。もしかして監視ツールとか入れないとできない？）

このプラクティスの解答例は[こちら](./.ans/swarm-service-resouces.md)

---

[TOP](../README.md)   
前: [サービスの配置](./swarm-service-placement.md)  
次: [サービスのボリュームマウント](./swarm-service-volume.md)  