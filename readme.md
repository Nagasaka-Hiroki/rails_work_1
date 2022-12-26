# Ruby on Railsを使ったプログラム（プロトタイプ)
　mainブランチで使うための機能を仮実装して試す。  
完成したものはmainブランチに取り入れていく。

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
コンテナ内から`rails new `を実行してプロジェクトを作成する。(ただ`rails new`した場合ブランチが`main`になるので追跡する前に`prototype`に切り替える。)

追記：  
イテレーション１の途中でdocker composeを使用する方向に変更した。以下のコマンドでコンテナが作成できる。

```bash
docker compose up -d
```

また、今回作ったdocker-compose.ymlのファイルは事前にDockerfileでイメージを作っていることを前提としている。以下のコマンドでイメージを作成する。

```bash
docker build -t rails_container:rails_on_jammy .
```

## livereload有効化
以下を参考に設定をする。
> - [https://github.com/guard/guard-livereload](https://github.com/guard/guard-livereload)
> - [https://techracho.bpsinc.jp/hachi8833/2022_02_04/115417](https://techracho.bpsinc.jp/hachi8833/2022_02_04/115417)
> - [https://rubygems.org/gems/rack-livereload/versions/0.3.17](https://rubygems.org/gems/rack-livereload/versions/0.3.17)
> - [https://github.com/jaredmdobson/rack-livereload](https://github.com/jaredmdobson/rack-livereload)
> - [https://github.com/guard/guard-livereload/issues/193](https://github.com/guard/guard-livereload/issues/193)

`./bin/dev`でサーバを起動してlivereloadの処理が入っていることを確認。有効化の手順は以上。

## open_firefox
　開発時にブラウザに毎回アクセスするのは面倒。なのでターミナルからブラウザを起動できるようにした。

使い方は単純で、以下のようにコマンドを入力する。
```bash
./open_firefox controller_name action_name id
```
上記コマンドでfirefox上で`http://172.17.0.2:3000/controller_name/action_name/id`のURLにアクセすることができる。

追記：  
IPアドレスが変更されている。スクリプトファイルは修正し、正常に動作するように変更した。