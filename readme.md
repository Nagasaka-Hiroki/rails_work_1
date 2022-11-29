# Ruby on Railsを使ったプログラム（プロトタイプ)
　mainブランチで使うための機能を仮実装してテストする。

## バージョン
|項目|バージョン|
|-|-|
|Ruby|3.1.2|
|Ruby on Rails|7.0.4|

作成段階の最新安定版を使用する。

## ブランチ
本リポジトリは以下のブランチが存在する。

|ブランチ|内容|
|-|-|
|main|開発本体|
|prototype|試作及びお試し実装|
|gh-pages|開発に関するドキュメント|

## 開発用のDockerfileとコンテナ
Dockerコマンドについて備忘録として記録する。

自分のリポジトリからダウンロードする。以下を実行する。
```bash
curl https://raw.githubusercontent.com/Nagasaka-Hiroki/rails_container/main/Dockerfile_dev_gu > Dockerfile
```
プロトタイプ用のディレクトリに移動して以下を実行し開発用イメージを作成する。
```bash
docker build -t rails_container:dev_gu .
```
開発を楽に進めるためにライブリロードを有効にしたい。そのため以下のgemを使用する前提でコンテナを作成する。
> - [guard/guard-livereload](https://github.com/guard/guard-livereload)

またこのgemの参考は以下のサイトが参考になった。
> - [Rails 7: guard-livereload gemで開発中にライブリロードする](https://techracho.bpsinc.jp/hachi8833/2022_02_04/115417)
これによればポートは35729を開ける必要があるそうだ。(デフォルトの場合)

よってコンテナ化は以下のコマンドで実行できる。
```bash
docker run --name dev_prototype -it -v $(pwd):/home/general_user/rails_dir -p 35729:35729  rails_container:dev_gu
```
コンテナ内から`rails new `を実行してプロジェクトを作成する。
