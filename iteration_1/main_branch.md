---
---

イテレーション1のメインブランチでの作業について記録する。

# メインブランチの作業記録
### 1. プロトタイプの整理
---
#### 1.1. プロトタイプのマージ
　プロトタイプで得られたコードをマージする。

いま、ブランチごとにディレクトリを分けているのでメインブランチのディレクトリに移動し以下を実行。

```bash
git pull -all
```

参考は以下。
- ["git pull origin master" の正体 - Qiita](https://qiita.com/nasutaro211/items/c590994a5d5091206c08)
- [Git - git-pull Documentation](https://git-scm.com/docs/git-pull)

しかし変わらなかったので以下を実行。

```bash
git pull origin prototype
```

しかし変わらない？  
→と思ったら、`git branch -r`とすればprototypeがあった。チェックアウトすればコードの一覧が表示された。

上記でひとまずマージの準備はできた。

マージはまず単純に実行してreadme.mdだけをもともとのmainブランチのものにする予定である。以下を実行。

```bash
git merge prototype 
fatal: refusing to merge unrelated histories
```

orphanブランチを作ったのが良くなかっただろうか？以下参考。

- [[Git] マージしようとするとrefusing to merge unrelated historiesが出たときの対処方法｜DevelopersIO](https://dev.classmethod.jp/articles/git-merge-option-allow-unrelated-histories/)

上記によれば根が共通でないとマージできないと書いている。その時のオプションについては`--allow-unrelated-histories`が有効だそう。以下リファレンス。
- [Git - git-merge Documentation](https://git-scm.com/docs/git-merge#Documentation/git-merge.txt---allow-unrelated-histories)

リファレンスを読むと、あまり良くない使い方らしい。gitの標準的な使い方について理解が足りていない可能性がある。

方法がわかったので以下を実行。

```bash
git merge --allow-unrelated-histories prototype
```

予想通りreadme.mdが衝突した。解決する。  
→VSCodeが非常にわかりやすく表示してくれた。mainブランチのファイルままにする。

状態を確認。

```bash
git status
ブランチ main
Your branch is up to date with 'origin/main'.

All conflicts fixed but you are still merging.
  (use "git commit" to conclude merge)

...
```

とりあえずunmergedがないのでOK。参考は以下。
- [Git - ブランチとマージの基本](https://git-scm.com/book/ja/v2/Git-%E3%81%AE%E3%83%96%E3%83%A9%E3%83%B3%E3%83%81%E6%A9%9F%E8%83%BD-%E3%83%96%E3%83%A9%E3%83%B3%E3%83%81%E3%81%A8%E3%83%9E%E3%83%BC%E3%82%B8%E3%81%AE%E5%9F%BA%E6%9C%AC)

表示の通り一度コミットする。  
→OK。`git log --graph`で確認するとマージできていることを確認できた。

#### 1.2. コードの整理
　プロトタイプは試験的にコードを作成している側面が強く、コードの一部がコメントとして残っていることがある。そのためそういった不要なコードをmainブランチから除外してきれいにする。

また、変数などは今回はそのままにする。適切ではない変数名（例えばUserモデルのuser_name)がある。しかし、今の所そこまで問題ではないと考えている（いい側面もあるから）。  
そのためこのままにする。（今のところは）。

上記の通り、まずは不要なコードを除外してきれいにしていく。

そのためにまず一度動かせるようにする。以下の操作を実行する。

1. docker-compose.ymlでコンテナ名を変更、ネットワークのアドレスを変更←ネットワーク名も変更する。
1. コンテナを作成して、必要なものをインストール、bundle install, npm install(ここは要確認)
1. スクリプトの一部を変更。

ひとまず上記で動きはするはずだ。実行する。

npm installについて以下参考。
- [npm-install](https://docs.npmjs.com/cli/v8/commands/npm-install)

npm installするとエラーが出た。調べるとyarn installかもしれない。  

一度やり直す。操作手順を書き直す。

1. docker-compose.ymlでコンテナ名、ネットワーク名を変更、ネットワークのアドレスを変更
1. コンテナを作成して、必要なものをインストール
```bash
bundle install
yarn install
```
1. スクリプトの一部を変更。

とりあえずこれでOKのはず。pullしたときに消えていた`node_modules`が現れたので動くはず。

---

yarn install時に以下の警告が出た。
```bash
warning " > @rails/actiontext@7.0.4" has incorrect peer dependency "trix@^1.3.1".
```
しかし、yarn.lockが変更された形跡がない（一度yarn install --forceしたにも関わらず）

そのため現状問題はないと予想されるため一度おいておく。問題が起きたらこれを疑う。

---

データベースが空だった。フィクスチャで流し込む。以下を実行。

```bash
./bin/rails db:drop
./bin/rails db:create
./bin/rails db:migrate
./bin/rails db:fixtures:load
```

これでプロトタイプで作った画面を確認する。  
→OK。きちんと動いた。

不要なコードを除外していく。  
→簡単にだが不要な箇所を削除できたはず。  
→ログイン、ルーム一覧表示、チャット表示などプロトタイプで中心的に作った機能は問題なく機能した。

しかし、一部エラーが出ているところがあるのでその点をしっかりと対応する。これは以下で実行する。
（例えば/roomsでaction cableを有効にしているが、その点をカバーしていなかった。）

現時点でコードがある程度整理できたので一度コミットしておく。

### 2. 不足分を実装する。
　プロトタイプでは、実装できるかわからない、理解が足りていないところを手を動かして理解する側面が強かった。そのため機能が部分的に不十分であったり、エラーが残っているところがある。そのためその分を補う。また、プロトタイプ製作開始時で想定していた設計と異なるところはこの段階で図面を書き直す。

