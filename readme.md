# FlowChat（Ruby on Railsを使ったプログラム）
　開発に関する記録は以下にある。開発背景や目的、設計などについて言及している。

[FlowChat開発記録](https://nagasaka-hiroki.github.io/rails_work_1/)

本プログラムはブラウザのクッキーとjavascriptを使用する。クッキーとjavascriptが無効の場合、上手く動かないことが予想されるためそれぞれを有効にしてください。

## RubyおよびRuby on Railsのバージョン
|項目|バージョン|
|-|-|
|Ruby|3.1.2|
|Ruby on Rails|7.0.4|

作成段階の最新安定版を使用する。

## 開発環境

|項目|バージョン|
|-|-|
|OS|Ubuntu 22.04.1 LTS|
|docker|20.10.22|
|docker compose|v2.14.1|
|ブラウザ|Firefox（開発時）|

対応ブラウザはChromeとFirefoxを目指しています。開発時は頻繁にブラウザを閉じるためFirefoxを採用しています。  
開発途中であるため全体的に動作が不安定です。特に、Chromeではより不安定になります。現状原因不明ですが改善できるように努めます。

開発はコンテナを使って行っています。コンテナの作成はDockerfileおよびdocker-compose.ymlを使って行い、どちらもUbuntu上で動作確認をしました。異なるOSの場合上手く動作しないことが予想されます。

以下のコマンドでコンテナを作成できます。

```bash
docker build -t rails_container:rails_on_jammy .
docker compose up -d
```

コンテナのIPアドレスは`172.19.0.2`を使用しています。他と競合する場合は変更をしてください。  
また、本プログラムはローカル環境で動作することを前提に作成しています。ゆえにサイバー攻撃の対策をしていないため、リスクの大きい環境で動作をさせないでください。

## 既存ユーザ
　Basic認証でログインするように製作しています。ユーザを新規登録して動作を確認できますが、フィクスチャファイルに既存ユーザを記述しています。以下代表例です。

|ユーザ名|パスワード|
|-|-|
|nkun|password|


## ブランチ
本リポジトリは以下のブランチが存在する。

|ブランチ|内容|
|-|-|
|main|開発本体|
|prototype|試作及びお試し実装|
|gh-pages|開発に関するドキュメント|
