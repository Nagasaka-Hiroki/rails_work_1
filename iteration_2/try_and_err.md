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

---

gitに関する小ネタ：

リポジトリからソースコードをダウンロードして`gh-pages`のブランチで作業をしていた。しかしブランチの切り替えが間違っている状態でコミットしていた。

この作業記録が残っていないがおそらく以下のように作業をしていたと思われる。

```bash
git clone https://github.com/Nagasaka-Hiroki/rails_work_1.git ./flow_chat_docs
cd ./flow_chat_docs
git checkout origin/gh-pages
```

しかし、これだとどうやら`no branch`で作業をすることになるそうだ。また、困ったことに作業内容をすでにコミットしていたのとステージングしていない箇所も発生していた。

この状態から以下のように作業をした。

```bash
git stash #作業内容を退避。コミットしている分はコミットのハッシュ値で追跡する。
git checkout -b gh-pages origin/gh-pages
#このときにno branchのコミットの識別番号が出るが、stashを作っているので忘れてもOKだと思う。
git stash list #ハッシュ値の先頭を確認（先頭だけで十分だった ）-> XXXXとする。
git merge XXXX #コミットを正しいブランチに取り込む。
git stash apply #コミットしていない変更内容を取り込む。確認してOKなら次を実行する。
git stash drop
```

これで`no branch`で作業した内容を復元することができた。また、単純に`git checkout origin/gh-pages`とするだけでは不十分という点を学習できた。きちんとローカルにブランチを作ることを念頭に入れないとだめだと言うことを教訓とする。

以下のサイトと本を参考にした。
- [Git で no branch に commit した時の対処法](https://at-aka.blogspot.com/2009/05/git-no-branch-commit.html)
- [【超初心者】実務で初の「git push origin ****」まで（めちゃくちゃヒヤヒヤしました） - Qiita](https://qiita.com/shimotaroo/items/ed08d76447144d566637)
- [【git stash】コミットはせずに変更を退避したいとき - Qiita](https://qiita.com/chihiro/items/f373873d5c2dfbd03250)

---

gitの小ネタ：

　新規作成のファイルの一部をステージングする際に詰まった。以下を実行するとできた。

```bash
git add -N new_file_name
```

以下が参考になった。
- [Gitで新規(Untracked)なファイルをadd patch(-p)する方法 - Qiita](https://qiita.com/toshi_dev/items/35d25ebb40968e808f6c)

---

