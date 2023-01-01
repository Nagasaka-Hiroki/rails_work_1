---
---

<h3>開発環境構築</h3>
　[開発環境と本番環境について]({{site.baseurl}}/dev_prd)で言及した通り本件のrailsアプリはDocker上で動作するように作成する。そのため開発段階で開発用のコンテナを導入する。
また、本番環境のコンテナについては開発がおおよそ完了した段階で導入する。しかし開発環境とあまりにかけ離れることは良くないと考えたためできるだけ差異を小さくできるように心がける。  

#### ベースイメージの選定
---
　開発用コンテナを作成するためのベースイメージを選定する。  
　本件におけるRubyとRailsのバージョンについては[開発環境と本番環境について]({{site.baseurl}}/dev_prd)で示したとおり以下のとおりである。

||バージョン|
|-|-|
|Ruby|3.1.2|
|Rails|7.0.4|

　Rubyをインストールできれば簡単にRailsをインストールできるため、この点を最も簡単に解決できる方法としてはDockerのオフィシャルイメージにある[Rubyイメージ](https://hub.docker.com/_/ruby)を使う方法だと考えられる。
しかし、この方法は以下の点で問題があると考えたため、<span style="color: red;">Ubuntu 22.04</span>のイメージをベースに作成していくことにした。

1. Ruby以外にも必要なツールがあること。（例：[sass](https://sass-lang.com/)、[Node.js](https://nodejs.org/ja/)、[yarn](https://yarnpkg.com/)）
1. ディストリビューションが基本的にalpineまたはdebianであること。
1. 学習の一端として環境構築はしっかりと経験したいこと。

　1と3にはある程度関係がある。Rubyがすでに入っているイメージを使えば簡単にRubyを導入できるが、その他のソフトもインストールしなければいけない。また、Dockerfileを書く練習や環境構築に必要なソフトがなにか調べることにもつながるため、ディストリビューションのイメージファイルから開始するのが良いと考えた。  
　2つ目に関してはN君のホストOSに関係がある。N君のホストOSはUbuntuであるため、コンテナ側もUbuntuにすれば発生する問題に関して経験したことがある可能性が高く、対処しやすいと考えたそのためRubyをインストールしたイメージは適切でないと考えたこと。Rubyイメージのベースとなるbuildpack-devsにはUbuntuもあるが、わざわざ探すよりUbuntuからはじめてインストールしたほうが早く完成でき、自分が何を使っているか明確になる利点もあるためUbuntuイメージを使用することを考えた。

#### イメージの改造
---
　前述の通り、開発用コンテナのベースイメージは[ubuntu:22.04](https://hub.docker.com/layers/library/ubuntu/22.04/images/sha256-817cfe4672284dcbfee885b1a66094fd907630d610cab329114d036716be49ba?context=explore)を選定した。このイメージにDockerfileを使用して以下の項目をインストール及び設定する。

1. 一般ユーザの追加(general_user)
1. Ruby([rbenv](https://github.com/rbenv/rbenv)によるインストール)
1. Rails
1. Node.js([nvm](https://github.com/nvm-sh/nvm)によるインストール)
1. yarn

　一般ユーザの追加は[Dockerfile のベスト・プラクティス](https://docs.docker.jp/develop/develop-images/dockerfile_best-practices.html)の観点や開発時のファイル編集を効率よく行うために実行する。Dockerは基本ユーザを追加しない限りrootユーザとして実行される。Docker単体で使う場合は問題ないが、本件はホスト側から頻繁にファイルを編集するためDocker側で作成（rails new など）したファイルの権限をいちいち書き換えるのは非常に手間がかかる。そのためDocker側とホスト側のユーザを合わせて置くことで権限の問題を回避しつつ、Dockerfileのベストプラクティスの注意点を満足できると考えたためユーザを追加する。  
　Ruby&Railsについては必須である。インストール方法は[rubyのダウンロードページ](https://www.ruby-lang.org/ja/downloads/)を参考にしサードパーティツールを使用した。rbenvを使用することで指定のバージョンをインストールする。  
　Node.jsおよびyarnについては必須ではない。しかしcssフレームワークを使用する場合を考えてインストールする。Node.jsのインストールはRubyの場合と同様にサードパーティツールを使用しインストールする。yarnについてはNode.jsと同時にインストールされる[npm](https://www.npmjs.com/package/npm)を使用してインストールできることが[yarnのホームページ](https://classic.yarnpkg.com/lang/en/docs/install/#debian-stable)に書かれているため、その方法を検討した。

#### Dockerfile化
---
　前述までの内容を考慮し`docker build`コマンドで開発環境を整えるDockerfileを作成した。Dockerfileは以下のリポジトリの[Dockerfile_dev_gu](https://github.com/Nagasaka-Hiroki/rails_container/blob/main/Dockerfile_dev_gu)として配置している。
- [https://github.com/Nagasaka-Hiroki/rails_container](https://github.com/Nagasaka-Hiroki/rails_container)

これで開発環境イメージの作成は以上である。

#### 追記：Docker Composeの導入
---
　開発を開始してしばらくは`docker run`コマンドでコンテナを作成していた。しかし、ネットワークの設定や環境変数など追加の設定がある場合、Dockerfileだけで運用するのが手間になってきた。そのためコンテナを作成する目的以外の設定については`dokcer-compose.yml`にまとめることでコンテナの作成の手間を減らすことにした。この場合コンテナ作成も単純に`docker compose up -d`とするだけで、設定などもファイルに明記することができるメリットがある。そのため本件では`docker compose`でコンテナの作成をすることにした。

　コンテナ作成はDockerfileとdocker-compose.ymlがあるディレクトリで、以下のコマンドを実行することで作成できる。

```bash
docker build -t rails_container:rails_on_jammy .
docker compose up -d
```

　docker composeでイメージをビルドできるが、すでにイメージは別途で作成済みであった。ビルド込みで実行すると非常に時間がかかる。そのためビルドは切り分ける構成にした。そのためイメージ作成コマンドとコンテナ作成コマンドの２段階で作成する。