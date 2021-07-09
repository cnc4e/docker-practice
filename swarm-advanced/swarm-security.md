[TOP](../README.md)   
前: [監視](./swarm-metrics.md)  
次: [準備中]()  

---

# セキュリティ

## 1. overlayネットワークの暗号化

overlayネットワークはホスト間に跨る通信です。overlayネットワークは暗号化できます。（暗号化するとネットワークのパフォーマンスに影響があります。いきなり本番で使用する前にパフォーマンスの問題がないか確認しましょう。）

なお、overlayネットワークを暗号化するにはノード間でESP(ip protocol:50)の通信を許可する必要があるのであらかじめ設定しておいてください。[ネタ元](https://docs.docker.com/engine/swarm/swarm-tutorial/#open-protocols-and-ports-between-the-hosts)

1. 以下満たすcomposeファイル`overlay-encrypted.yaml`を作成してください。

- service名: nginx
  - image: nginx
  - deploy mode: replicated
  - replicas: 1
  - networks: encrypted
- service名: httpd
  - image: httpd
  - deploy mode: replicated
  - replicas: 1
  - networks: encrypted
- network名: encrypted
  - driver: overlay
  - driverオプション: `encrypted: ""`を指定

2. 上記作成したcomposeファイルを指定し、スタック`test`を作成してください。

3. スタックの一覧、スタック内のサービス一覧、スタック内のタスク一覧をそれぞれ表示し、タスクが2つデプロイされていることを確認してください。また、nginxのタスクがスケジュールされたノードを確認しておいてください。（後で接続します。）

4. ネットワークの一覧を表示し、`test_encrypted`という名前のoverlayネットワークがあることを確認してください。

5. ネットワーク`test_encrypted`の詳細情報を表示してください。オプションに`encrypted: ""`が設定されていることを確認してください。（IPAMのオプションではないので注意）

6. **nginxが動いているノード** に接続しnginxのコンテナからservice名を指定してhttpdにcurlしてください。問題なく通信できることを確認してください。

7. スタック`test`を削除してください。

## 2. イメージの脆弱性診断

## 3. セキュリティ診断

## 4.その他tips

以下、本プラクティスではとくに課題を用意していませんが一般的なセキュリティ関連のtipsを以下に記載します。

- ホストに余計なソフトはインストールしない
- ホストのOSグループ`docker`に一般ユーザを所属させない
- ベースイメージは信頼できる提供元のものを使う
- イメージには必要最小限のものしか入れない
- コンテナ実行ユーザはroot以外を使用する
- shやbashなどのコマンドはコンテナから削除する
- 特権コンテナは安易に作らない
- パスワードなどのシークレット情報はコンテナイメージ、composeファイルに埋め込まない
- docker apiを外部に公開するときはTLSやSSHで保護する

また、コンテナ環境のセキュリティ指針として有名なもので米国国立標準技術研究所（NIST）という団体が公開したSP800-190という文章があります。日本の情報処理推進機構（IPA）により日本語訳されたものが[こちら](https://www.ipa.go.jp/files/000085279.pdf)にありますのでより詳細に検討したい方は是非読んでみてください。

*[解答例](./.ans/swarm-security.md)*

---

[TOP](../README.md)   
前: [監視](./swarm-metrics.md)  
次: [準備中]()  
