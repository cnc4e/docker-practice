[TOP](../README.md)   
前: [docker-composeによる複数コンテナの連携](./compose-multi.md)  
次: -  

---

# まとめ

ここまでの内容を振り返ります。

1. ``compose-summary``ディレクトリを作成し移動してください。

2. ``index.html``を作成してください。内容は何でも良いです。

3. 以下を満たす``docker-compose.yml``を作成してください。（composeファイルの書き方は[日本語マニュアル](https://docs.docker.jp/compose/compose-file.html#)を参考にする）
   - version: 3
   - ``test``という名前のネットワークを作成
     - ドライバは``bridge``
   - ``client``という名前のサービスを作成
     - イメージは``nginx:1.19.2``
     - ログドライバは``journald``
     - 環境変数``TARGET``に``server``を設定
     - ネットワーク``test``に所属
   - ``server``という名前のサービスを作成
     - イメージは``nginx:1.19.2``
     - ログドライバは``journald``
     - ホストの``8080``をコンテナの``80``に接続 
     - ホストの``./index.html``をコンテナの``/usr/share/nginx/html/index.html``にマウント
     - ネットワーク``test``に所属

4. 上記``docker-compose.yml``を使いコンテナをバックグランドで起動してください。

5. コンテナが動いていることを確認してください。

6. サービス``client``のコンテナにログインし環境変数の設定を確認してください。

7. サービス``client``のコンテナから以下のコマンドを実行し作成したindex.htmlの内容が表示されることを確認してください。
   ``` sh
   curl -s $TARGET
   ```

8. ホストOSから以下のコマンドを実行し作成したindex.htmlの内容が表示されることを確認してください。
   ``` sh
   curl -s localhost:8080
   ```

9. 以下コマンドでjournalにコンテナのログが出力されていることを確認してください。
   ``` sh
   journalctl -xe
   ```

10. dokcer-composeでコンテナを削除してください。

---

[TOP](../README.md)   
前: [docker-composeによる複数コンテナの連携](./compose-multi.md)  
次: -  
