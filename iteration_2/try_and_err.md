---
---
<style type="text/css" media="screen">
    h5 {
        font-size: 17px;
    }
    h6 {
        font-size: 16.5px;
    }
</style>

### イテレーション2 試行錯誤
　フロントエンドの開発を短縮するためにChatGPTを利用する。利用規約に違反しないように生成したコードは直接使わない。あくまで学習を目標として利用する。

イテレーション2ではチャート機能を実装する。そのため、基本的にチャット（`div`要素）どうしを線で結ぶことを考える。

ブラウザ上で線を各方法はいくつかある。

1. canvasを使う。
1. svgを使う

それぞれの特徴は以下に記されている。

- [HTML5での描画を実現するSVGとCanvasを改めて比較する ｜ SiTest (サイテスト) ブログ](https://sitest.jp/blog/?p=2498)

ざっくりまとめると、canvasは細かい描画が得意。svgは劣化しにくいが細かい描画が苦手という感じ。

とりあえずsvgでやってみる。

#### 環境再構築
まず、OSを入れ直しているので開発環境を再構築。

リポジトリを取得して、作業ブランチを作成。その後にイメージを作成しコンテナを作成。コンテナに入ってコマンドを打ち込んでプログラムをインストールする。

覚書だが以下に示す。

```bash
git clone https://github.com/Nagasaka-Hiroki/rails_work_1.git ./flow_chat
#sshで接続したいので以下を実行する。
# git remote set-url origin git@github.com:Nagasaka-Hiroki/rails_work_1.git
cd flow_chat
git checkout -b iteration2_prototype
docker build -t rails_container:rails_on_jammy .
docker compose up -d

#以下はコンテナ内での操作
docker exec -it rails_main /bin/bash
bundle install
yarn install
./bin/rails db:drop
./bin/rails db:create
./bin/rails db:migrate
./bin/rails db:fixtures:load

#コンテナでは
./bin/dev #これでサーバーを起動する。
#ホスト側で以下を実行する。これを実行するとfirefoxが起動してチャット画面が開く。
./open_firefox_nkun rooms 1
```

これでセットアップ完了。

