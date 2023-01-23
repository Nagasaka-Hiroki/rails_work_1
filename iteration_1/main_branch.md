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
---
　プロトタイプでは、実装できるかわからない、理解が足りていないところを手を動かして理解する側面が強かった。そのため機能が部分的に不十分であったり、エラーが残っているところがある。そのためその分を補う。また、プロトタイプ製作開始時で想定していた設計と異なるところはこの段階で図面を書き直す。

---

追記： `yarn install`について  
上記では、npm installではなくyarn installとyarn install --forceをした。--forceオプションをつけたのはディレクトリが表示されなかったからだ。しかし、気になったので別ディレクトリにクローンして試したところ、yarn installでnode_modulesが生成された。クローン後に実行するべきはnode_moduelsを生成するためにyarn installを実行すればいいことがわかった。(表示されるのに時間がかかった。手動で更新した場合に表示された。)

また、上記でyarn install --forceを実行したがyarn.lockが変化なしである点から今回は実行自体に問題はない。そのまま進める。

---

プロトタイプのブランチ名にイテレーションの番号があったほうがわかりやすいので新しくブランチを作る。

```bash
git checkout -b prototype_iteration_1
```

上記の状態だと、`prototype_iteration_1`と`prototype`はほとんど同一だが、わかりやすさのためにそのままにする。

調整の前にすべきことはおおよそ済んだと思われるので、調整に入る。

#### 2.1 図の修正
　これまで、いくつか図を書いてきた。しかしコードを作成する過程で変更があったものがある。それらについて図を書き直す。

##### 2.1.1 ER図
まず、ER図について修正する。修正点はチャットモデル。以前は直接発言内容が直接保存されるようにしていたが、中間テーブルとして扱うようにした。これは後々発言内容に属性をつけたりする上で便利だったり、発言内容保存の問題（action textの問題)とそれ以外の問題を分離できる（モデルにaction text以外が入る割合が小さくなるため問題が切り分けやすく単純化できると期待できる）。そういった意味で切り分けた。その後のER図について書き直す。  
また、以前の図をみると多重度の記号が書き間違えていた。またrailsでは主キーは特に理由がない限りidのみである。その点を修正する。  
また、現時点では一人で使うひとり言機能を実装するが、この段階で複数人で使用することを想定したほうが後からの変更が少ないと考えた。そのため多重度が一つではなく複数になっている箇所がある。

|![修正後のER図]({{site.baseurl}}/assets/images/iteration_1/modified_er_diagram.png)|
|:-:|
|修正後のER図（イテレーション１）|

action textに関する設定を多くする場合は上記のER図では不十分かもしれないが、プロトタイプを作った状態では問題ないと感じるため上記の図としての実装で問題ないとする。

##### 2.1.2 画面遷移図
　画面遷移図については一部変更とToDo機能・ひとり言機能の追加によって画面数が増えた。その分を考慮するために新しく図を作る。以下に示す。

|![画面遷移図]({{site.baseurl}}/assets/images/iteration_1/iteration_1_view_transition.png)|
|:-:|
|画面遷移図（イテレーション１)|

上記の図のルームはチャット機能を使うための場所を意味している。またルーム一覧となっているが現状はToDo・ひとり言の機能しか作らないので一つしか表示されない。  

基本認証画面とあるが、その場でアクセスしたときにブラウザ上部に現れるポップアップのことを指している。そのため画面自体の作成はrailsがしてくれている。

##### 2.1.3 認証処理のアクティビティ図
　プロトタイプ作成段階で処理の大まかな流れ自体は掴むことができていた。しかし具体的な方向性については明記できていなかった。そのためプロトタイプで明らかになった点を整理しながら認証の処理の流れをアクティビティ図として表す。

|![認証処理]({{site.baseurl}}/assets/images/iteration_1/auths_procedure.png)|
|:-:|
|認証処理（イテレーション１)|

認証にはBasic認証を用いる。これはプライベートネットワーク内で使用するためセキュリティに配慮する必要が少ない点。またいきなり高度な認証を実装するのは難しいことから、最も単純なBasic認証を選択した。

ログイン処理は特に問題ない。railsの機能を使えば比較的簡単に実装することができる。  
問題はログアウトである。プロトタイプ作成によって以下のポイントがあることがわかった。

1. ログアウトは無意味な認証情報で認証を成功させる。
1. 再ログインのためには、一度認証情報を空にする。

１つ目は、ブラウザが認証情報を保存してしまうための対応である。ログアウトしたいのにブラウザが覚えると問題である。そのため偽認証情報を付与した状態で認証に成功させることで、偽認証情報を記憶させる。これによってブラウザバックしても再ログインできない状態ができる。  
２つ目は念の為の処理である。偽認証情報を持った状態で選択画面に移行すると認証が不要な画面に認証情報を持って遷移するといった類のポップアップが表示される。再ログインにおいては問題ないが、面倒なのでこの処理を入れている。

上記までで以前に書いた図の修正は完了である。

#### 2.2 ルーティングの修正
　プロトタイプ作成開始時に考えていたルーティングと異なる結果になった。その結果についてまとめる。(`./bin/rails routes`で確認する。)

|Verb|URI Pattern|Controller#Action|動作|
|-|-|-|
|GET   |/                       |auths#show   |選択画面を表示|
|GET   |/auths/logout(.:format) |auths#logout |ログアウト画面を表示|
|GET   |/auths/mypage(.:format) |auths#mypage |マイページを表示|
|GET   |/auths/new(.:format)    |auths#new    |ユーザの新規登録画面|
|GET   |/auths(.:format)        |auths#show   |選択画面を表示|
|POST  |/auths(.:format)        |auths#create |入力情報を元にユーザを作成|
|GET   | /rooms(.:format)       |rooms#index  |ルーム一覧表示|
|GET   | /rooms/:id(.:format)   |rooms#show   |ルームの内容を表示|

ルーム作成のルーティングがないが、ToDo・ひとり言機能ではユーザの作成と同時にユーザ名と同一のルーム名を作成するため不要としている。

上記のルーティングではRESTfulな設計とは言えない。少なくとも上記のルーティングに以下を加える必要がある。

|Verb|URI Pattern|Controller#Action|
|-|-|-|
|GET   |/auths/edit(.:format)      |auths#edit   |
|PATCH |/auths(.:format)           |auths#update |
|PUT   |/auths(.:format)           |auths#update |
|DELETE|/auths(.:format)           |auths#destroy|
|POST  | /rooms(.:format)          |rooms#create |
|GET   | /rooms/new(.:format)      |rooms#new    |
|GET   | /rooms/:id/edit(.:format) |rooms#edit   | 
|PATCH | /rooms/:id(.:format)      |rooms#update |
|PUT   | /rooms/:id(.:format)      |rooms#update |
|DELETE| /rooms/:id(.:format)      |rooms#destroy|

しかし、ToDo・ひとり言としては重要でない機能ばかりである。そのため機能の作り込みの本質ではないので今は実装しないことにする。  
しかしシステムとしては必要なものばかりである。そのため後回しになるが後々の完成度を上げるために実装は必要である。あくまで優先順位の問題として今は切り捨てるという理解をする。

はじめに示したルーティングを実装すれば最低限動く（情報の修正やデータの破棄はできないが）ものができるはずだ。そのため実装のための必要最低限として考え、その実装を目標とする。

#### 2.3 ドキュメントの追加
　現段階でまとめた結果を[プロトタイプ作成]({{site.baseurl}}/iteration_1/prototype)などに追加していく。  
当初予定していた項目だと上手くかけないところは適宜修正する。  
→項目を修正しつつドキュメントを作成した。テスト設計までをおおよそ書いた。しかしテスト項目自体作ったが少し曖昧なのでテストを書きつつ追加していく。

#### 2.4 テストの作成と実行
　[ユースケースとテスト設計]({{site.baseurl}}/iteration_1/test_design)で検証するべき項目について検討した。しかし前述の通り、検討が不十分だと思うので作りながらドキュメントに追加していく。

まずはモデルテストとモデルに不足している機能について実装する。

その前に一度知識を整理する。

- モデル  
　モデルにはバリデーションがある。以下参考。

- [ Active Record バリデーション - Railsガイド](https://railsguides.jp/active_record_validations.html)
- [ActiveRecord::Validations](https://api.rubyonrails.org/classes/ActiveRecord/Validations.html)
- [ActiveRecord::Validations::ClassMethods](https://api.rubyonrails.org/v7.0/classes/ActiveRecord/Validations/ClassMethods.html#method-i-validates_associated)
- [ Active Record バリデーション - Railsガイド](https://railsguides.jp/active_record_validations.html#validates-associated)


また、本を読んでいるとバリデーションにはいろんな種類があるそうだ。

中でも単純なものは`validates`メソッドで検証できるそうだ。そのため、まずは`validates`で実装できるか検討し、そうでない場合やそれ以外のほうが簡単に実装できる場合にその他を検討するという具合に考えるのが妥当だろう。

テスト設計の内容と対応しそうな検証名の対応と考える。以下に示す。

|テスト内容|検証名orメソッド名|
|-|-|
|値が唯一か？|:uniqueness|
|空出ないか?|:presence|
|文字数の範囲内か？|:length|
|半角英数字か？|:format|
|レコードが存在する|validates_associated|

また、上記の検証名などはバリデーションヘルパーというそうだ。調べごとのときに使うと便利そうだ。

validates_associated以外は単純そうなので、先に作成する。validates_associatedについては後でコンソールで試して挙動を確認する。

また、validates_associatedは中間テーブルに実装する。なぜなら中間テーブル側に実装することでテストを集約できたり、似た記述をまとめることができるからだ。

##### 2.4.1 Userモデル
　バリデーションを以下のように追加した。

```ruby
    #モデルの検証ルールを追加する。
    validates :user_name,      #ユーザ名の検証ルール
        uniqueness: true,      #唯一である。
        presence:   true,      #空を許可しない。
        length: { in: 1..15 }, #1文字以上16文字未満。
        format: { with: %r{[a-zA-Z\d]*} } #半角英数字のみを許可する。空白は許可しない。

    validates :password,       #パスワードの検証ルール
        presence:   true,      #空を許可しない。
        length: { in: 1..15 }, #1文字以上16文字未満。
        format: { with: %r{[a-zA-Z\d]*} } #半角英数字のみを許可する。空白は許可しない。
```
テストは以下で作った。
```ruby
  #成功を期待するパターン
  test "create test" do
    #新しい名前のユーザ、空でないユーザ名、半角英数字で空白を許可しない。
    #パスワードは空でない、半角英数字で空白を許可しない。
    user = User.create(user_name: "SampleUser", password: "SamplePass")
    assert user, "正しく作成されませんでした。バリデーションが間違っています。"
  end
  #失敗を期待するパターン1
  test "fail create test" do
    #半角英数字以外の記号と空白を突っ込んだ情報かつ16文字以上
    user = User.create(user_name: "!\"#$%&'()=-~^ |\\{}*;+_?/><", password: "!\"#$%&'()=-~^ |\\{}*;+_?/><")
    assert_not user, "正しく作成されました。バリデーションが間違っています。"
  end
  #失敗を期待するパターン2 1が失敗しないので追加で検証
  test "fail create test2" do
    #空白を許さない。
    user = User.create(user_name: " ", password: " ")
    assert_not user, "空白であるにも関わらず正しく作成されました。バリデーションが間違っています。"
  end
```
しかし、成功しない。ポケットリファレンスを読むとバリデーションの失敗はfalseか例外で判定するとあるので`assert_not`を使うのは間違いではないと思われる。一度コンソールで確認する。

```ruby
irb(main):023:0> b=User.create(user_name: " ", password: " ")
  TRANSACTION (0.3ms)  SAVEPOINT active_record_1
  User Exists? (0.4ms)  SELECT 1 AS one FROM "users" WHERE "users"."user_name" = ? LIMIT ?  [["user_name", " "], ["LIMIT", 1]]
  TRANSACTION (0.3ms)  ROLLBACK TO SAVEPOINT active_record_1    
=> #<User:0x00007f27bd137428 id: nil, user_name: " ", password: "[FILTERED]", created_at: nil, updated_at: nil>
irb(main):027:0> c=User.create!(user_name: " ", password: " ")
  TRANSACTION (0.2ms)  SAVEPOINT active_record_1
  User Exists? (0.4ms)  SELECT 1 AS one FROM "users" WHERE "users"."user_name" = ? LIMIT ?  [["user_name", " "], ["LIMIT", 1]]
  TRANSACTION (0.2ms)  ROLLBACK TO SAVEPOINT active_record_1  
/home/general_user/.rbenv/versions/3.1.2/lib/ruby/gems/3.1.0/gems/activerecord-7.0.4/lib/active_record/validations.rb:80:in `raise_validation_error': Validation failed: User name can't be blank, Password can't be blank (ActiveRecord::RecordInvalid)                             
irb(main):028:0> c.nil?
=> true
```
試しに空白のユーザ名とパスワードを試した。結果はロールバックされているので失敗している。挙動としては以下。

1. create　→　なにかのオブジェクトが入っている。なのでb.nil?はfalseになる。
1. create! →　例外が発生。また、中身もからなのでc.nil?はtrueになる。

そのためテストコードが間違っているようだ。!なしのメソッドは比較的寛容であるが、判定する上では注意が必要。!をつけて再度検証する。

次は失敗が返った。理由は例外が出たから。そのためアサーションメソッド？を例外を拾うように変更する。

上記を参考に例外を検索した。以下を参考。

- [ActiveRecord::RecordInvalid](https://api.rubyonrails.org/classes/ActiveRecord/RecordInvalid.html)

コンソールで試すとバリデーション自体は上手く行ってそうだった。また上記サイトでもsave!メソッドのレコードが無効な場合に発生すると書かれている。そのため上記で問題ないはずだ。

createに関するミソは次の通り。

1. createで失敗した場合、例外は発生しない。しかし返り値はnil or falseではなく、createしたクラスのオブジェクトがデータベースに保存されずに代入される。ただし、idやタイムスタンプはnilになる。
1. create!で失敗した場合、例外が発生する。例外の種類は様々だが、バリデーションによって無効なレコードが発生した場合はActiveRecord::RecordInvalidになる。返り値はnilになる。そのため判定としてはfalseと同義になる。そのためテストでアサーションする場合は例外を拾う形で対応する。

上記のことに注意してテストを書き直した。失敗のケースが2つあるのは原因調査のための名残である。

```ruby
  #成功を期待するパターン
  test "create test" do
    #新しい名前のユーザ、空でないユーザ名、半角英数字で空白を許可しない。
    #パスワードは空でない、半角英数字で空白を許可しない。
    user = User.create!(user_name: "SampleUser", password: "SamplePass")
    assert user, "正しく作成されませんでした。バリデーションが間違っています。"
  end
  #失敗を期待するパターン1
  test "fail create test" do
    #半角英数字以外の記号と空白を突っ込んだ情報かつ16文字以上
    assert_raises(ActiveRecord::RecordInvalid) do
      @user_case1 = User.create!(user_name: "!\"#$%&'()=-~^ |\\{}*;+_?/><", password: "!\"#$%&'()=-~^ |\\{}*;+_?/><")
    end
    assert_nil @user_case1, "正しく作成されました。バリデーションが間違えています。"
  end
  #失敗を期待するパターン2 1が失敗しないので追加で検証
  test "fail create test2" do
    #空白を許さない。
    assert_raises(ActiveRecord::RecordInvalid) do
      @user_case2 = User.create!(user_name: " ", password: " ")
    end
    assert_not @user_case2, "空白であるにも関わらず正しく作成されました。バリデーションが間違っています。"
  end
```

テスト結果はOK。問題なく成功した。これでUserモデルのテスト項目はOK。

---

追記：  
機能の不足を発見。ユーザ作成時にひとり言ルームを作成することを忘れていた。機能を追加してテスト項目を追加し、テストする。

Userのインスタンス作成時にルームを作成するのでコールバックが有効だと思う。これはアカウント作成時に実行できればいいので`after_create`を使用するといいと思う。  
→追加しようとしたところコントローラにすでに記述されていた。コントローラのcreateメソッドに書いていたので、明らかにユーザ作成時に実行される。そのためこのままでいいと思う。

---

##### 2.4.2 Roomモデル
　Roomモデルはほとんどユーザモデルと同一である。そのため比較的簡単。

##### 2.4.3 ChatTextモデル
　問題はこれ。フィールドが特に定義されていない。とりあえず上記と同様に、contentに対して実行してみる。

コンテントに関する改行と空を許可しないのために正規表現を作る。以下のツールが便利である。

- [Rubular: a Ruby regular expression editor](https://rubular.com/)

また、肯定後読み・先読み、正規表現の基本的な書き方などについて以下で学習した。

- [正規表現｜先読みと後読みを使ったパターン](https://www.javadrive.jp/regex-basic/writing/index2.html)
- [基本的な正規表現一覧｜murashun.jp](https://murashun.jp/article/programming/regular-expression.html)
- [とほほの正規表現入門 - とほほのWWW入門](https://www.tohoho-web.com/ex/regexp.html#non-greedy)
- [タグの中身だけ取り出したい正規表現 - Qiita](https://qiita.com/nemui_yo/items/dea01f0c971bb4c17d20)

Rubyの正規表現については以下を参考。
- [正規表現 (Ruby 3.2 リファレンスマニュアル)](https://docs.ruby-lang.org/ja/latest/doc/spec=2fregexp.html)
- [正規表現 (Ruby 3.2 リファレンスマニュアル)](https://docs.ruby-lang.org/ja/latest/doc/spec=2fregexp.html)
- [class Regexp (Ruby 3.2 リファレンスマニュアル)](https://docs.ruby-lang.org/ja/latest/class/Regexp.html)

まず入力データ（成功）をマッチさせる。例は以下。

```ruby
"<div>a</div>"
```
抽象度が低い正規表現は以下。
```ruby
reg=%r{(?<=<...>).*(?=</...>)}
```
マッチ結果は以下。
```ruby
irb(main):037:0> reg.match("<div>a</div>")
=> #<MatchData "a">
```

目標はタグ名に関わらずinnerhtml要素をとりだすことだ。"..."の箇所の抽象度をあげられるか検討する。

いろいろ試したが無理だった。以下参考。
- [Ruby正規表現の後読みでは長さ不定の量指定子は原則使えない｜TechRacho by BPS株式会社](https://techracho.bpsinc.jp/hachi8833/2021_10_14/49115)

できないというのが結論らしい。

そのため別の方法を検討する。

###### 2.4.3.1 ChatTextモデル 空白を許可しない。
まず空を許可しない部分を追加。ChatTextモデルには以下の方法でバリデーションを追加できた。

```ruby
    #バリデーションのルールを追加する。
    validates   :content,    #コンテンツの検証ルール
        presence:   true     #空を許可しない。
```

この状態で以下のテストコードを実行した。

```ruby
  #作成に失敗するパターン１　空の場合
  test "empty test" do
    empty_chat_text = ChatText.create! content: ""
  end
#→ActiveRecord::RecordInvalidが発生
```

`ActiveRecord::RecordInvalid`はUserモデルのときも発生した。これはレコードの値が無効なときに発生する例がである。また、バリデーションの部分をコメントアウトすれば何事もなく終了した。そのためバリデーションの効果は確かにあると言えるだろう。

そのため、この`ActiveRecord::RecordInvalid`の例外を拾うテストを書く。  
```ruby
  #作成に失敗するパターン１　空の場合
  test "empty test" do
    assert_raises(ActiveRecord::RecordInvalid) do
      @empty_chat_text = ChatText.create! content: ""
    end
    assert_not @empty_chat_text, "create!にも関わらずfalseでない。バリデーションが間違っています。"
  end
```
→OK。空白の場合、例外が発生してインスタンスが生成されなかった。

###### 2.4.3.2 ChatTextモデル タグ内の空白、改行とノーブレークスペースのみの禁止
　通常の空の送信は上記で弾くことはできた。しかし空白のみとノーブレークスペースで送信される場合、それらはhtmlタグに囲まれて受信する。そのため上記の空白を許可しない場合を貫通する。そのため正規表現で許可しないパターンを記述しようとしたがタグの認識を上手く書くことができないため別の方法を検討する必要がある。それがこの項の目的である。

検討した結果、Nokogiri gemを使うのがいいと考えた。Nokogiriはhtmlパーサーでおそらく、rubyの中では最も多く使われているものだと思う。以下に示す。
- [Category: HTML parsing - The Ruby Toolbox](https://www.ruby-toolbox.com/categories/html_parsing)

上記の信憑性については不明である。しかし日本語の記事が多く見つかるのである程度使われているはずだ。本格的にhtml解析をするわけではないので学習しやすいというのは重要。そのためNokogiriを使用するのがいいと思う。dockerで`gem which nokogiri`と打ち込むとヒットしたが、Gemfileで管理しているのでGemfileに追加をする。以下参考。

- [nokogiri｜RubyGems.org｜your community gem host](https://rubygems.org/gems/nokogiri)
- [Nokogiri](https://nokogiri.org/)
- [Rubyでhtmlを整形したり、不要なタグを削除する – 株式会社ルーター](https://rooter.jp/web-crawling/ruby_html_disused_tags/)

Gemfileに追加してbundle installを実行する。

Nokorigiの使い方を、ブログと公式ドキュメントを見て調べる。以下が参考になる。
- [Nokogiriのtextとinner_htmlについて - Qiita](https://qiita.com/knt45/items/74f7f6f82ba47b69d1b9)
- [module Nokogiri::HTML5 - RDoc Documentation](https://nokogiri.org/rdoc/Nokogiri/HTML5.html)
- [class Nokogiri::HTML5::DocumentFragment - RDoc Documentation](https://nokogiri.org/rdoc/Nokogiri/HTML5/DocumentFragment.html)
- [ File: README — Documentation for sparklemotion/nokogiri (main) ](https://www.rubydoc.info/github/sparklemotion/nokogiri)
- [ Method: Nokogiri::HTML5::DocumentFragment.parse — Documentation for sparklemotion/nokogiri (main) ](https://www.rubydoc.info/github/sparklemotion/nokogiri/Nokogiri%2FHTML5%2FDocumentFragment.parse)
- [Nokogiri の使い方-Qiita](https://qiita.com/tommy_1592/items/07fa571232a9b8bb96de)
- [スクレイピングエンジニアなら知っておきたいNokogiriの使い方8選 – 株式会社ルーター](https://rooter.jp/web-crawling/scraping_with_nokogiri/)

上記を参考にirbで試してみる。

```ruby
irb(main):001:0> require "nokogiri"
=> true
irb(main):002:0> doc = Nokogiri::HTML::DocumentFragment.parse("<div>test text</d
iv>")
=> 
#(DocumentFragment:0x5690 {                                              
...                                                                      
irb(main):003:0> doc
=> 
#(DocumentFragment:0x5690 {                                              
  name = "#document-fragment",                                           
  children = [                                                           
    #(Element:0x57bc { name = "div", children = [ #(Text "test text")] })]
  })               
irb(main):008:0> doc.inner_html
=> "<div>test text</div>"
```

更に調べて上にリンクを追加。

irbで実験を続ける。

```ruby
html=<<EOL
<div>
  <p>first</p>
  <p>second</p>
  <div>
    <p>third</p>
  </div>
</div>
EOL
doc=Nokogiri::HTML::DocumentFragment.parse(html)
=> 
#(DocumentFragment:0x142bc {                                                    
...                
doc.text
=> "\n  first\n  second\n  \n    third\n  \n\n"
irb(main):041:0> br="<div><br /></div>"
=> "<div><br /></div>"
irb(main):036:0> doc.at('br')
=> nil
irb(main):037:0> 
irb(main):038:0> doc.search('br')
=> []
irb(main):039:0> doc.search('br').empty?
=> true
irb(main):040:0> doc.search('div')
=> [#<Nokogiri::XML::Element:0x143e8 name="div" children=[#<Nokogiri::XML::Text:0x1a57c "\n  ">, #<Nokogiri::XML::Element:0x14578 name="p" children=[#<Nokogiri::XML::Text:0x1a590 "first">]>, #<Nokogiri::XML::Text:0x1a5a4 "\n  ">, #<Nokogiri::XML::Element:0x147a8 name="p" children=[#<Nokogiri::XML::Text:0x1a5b8 "second">]>, #<Nokogiri::XML::Text:0x1a5cc "\n  ">, #<Nokogiri::XML::Element:0x149d8 name="div" children=[#<Nokogiri::XML::Text:0x1a5e0 "\n    ">, #<Nokogiri::XML::Element:0x14b68 name="p" children=[#<Nokogiri::XML::Text:0x1a5f4 "third">]>, #<Nokogiri::XML::Text:0x1a608 "\n  ">]>, #<Nokogiri::XML::Text:0x1a61c "\n">]>, #<Nokogiri::XML::Element:0x149d8 name="div" children=[#<Nokogiri::XML::Text:0x1a5e0 "\n    ">, #<Nokogiri::XML::Element:0x14b68 name="p" children=[#<Nokogiri::XML::Text:0x1a5f4 "third">]>, #<Nokogiri::XML::Text:0x1a608 "\n  ">]>]                                                                    
irb(main):041:0> br="<div><br /></div>"
=> "<div><br /></div>"
irb(main):042:0> brdoc = Nokogiri::HTML::DocumentFragment.parse(br)
=> #(DocumentFragment:0x7fa1c { name = "#document-fragment", children = [ #(Element:0x7fb48 { name = "div", children = [ #(Element:0x7fc74 { name = "br" })] })] })
irb(main):043:0> brdoc.search('br')
=> [#<Nokogiri::XML::Element:0x7fc74 name="br">]
irb(main):045:0> nb="<div>&nbsp;</div>"
=> "<div>&nbsp;</div>"
irb(main):046:0> nbdoc=Nokogiri::HTML::DocumentFragment.parse(nb)
=> #(DocumentFragment:0x974f0 { name = "#document-fragment", children = [ #(Element:0x9761c { name = "div", children = [ #(Text " ")] })] })
irb(main):048:0> nbdoc.text
=> " "
irb(main):049:0> nbdoc.inner_html
=> "<div> </div>"
```

上記の実験で次の手順で次のことがわかった。

1. doc=Nokogiri::HTML::DocumentFragment.parse(html)で解析ができる。
1. doc.textでhtmlのタグ要素内のテキスト（改行を含む）が取得できる。
1. doc.search('br')で改行タグの一覧を配列として受け取ることができる。
1. ノーブレークスペースはNokogiri内では空白扱いになる。（←曖昧だがサーバに送信される状態で試した結果空白になった）

そのため、比較的単純に解析できると思う。以下の手順で解析できるはずだ。

1. パースする。
1. テキストをすべて取得。空白と改行以外あるか調べる。
1. 空白と改行以外があれば、終了。

少し難しく考えすぎていた。brタグがあろうと無かろうと、テキストがあればOKなので上記で十分である。早速実装する。

と言っても標準のバリデーションに比べるとすこし複雑になる。この場合`validate`メソッドを使うのが良いはずだ。以下に示す。
- [ActiveModel::Validations::ClassMethods](https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validate)

自分で作成するメソッドの戻り値は関係ないそうだ。ポイントはerrosにエラー情報を追加するのが良いそうだ。またエラーの場合は例外を発生させることを忘れてはいけない。

まずは以下の記述で動くか確認する。
```ruby
    #新しいバリデーションルールを追加する
    validate :text_exists?

    private
    def text_exists?
        p "private method"
        #p self
        #p self.content
    end
```
テストコードは以下。
```ruby
  #作成に失敗するパターン２　タグに囲まれた、空白と改行（&nbsp;と<br>)
  #動作確認でまずは成功させる。
  test "space text test" do
    space_text = ChatText.create! content: "<div>test text</div>"
  end
#→"private method"　とターミナルに表示。
#p selfに変更すると#<ChatText id: nil, created_at: nil, updated_at: nil>が表示された。
#p self.contentにすると#<ActionText::RichText id: nil, name: "content", body: #<ActionText::Content "<div class=\"trix-conte...">, record_type: "ChatText", record_id: nil, created_at: nil, updated_at: nil>が表示される。
```

create!時にメソッドが呼び出されることがわかった。後は実装を正しく行う。

htmlの断片は`self.content.body`で取得できる。ここでNokogiriと合わせて処理を行う。  
→と思ったが、引数に渡すとエラーになった。Stringにしろといったエラーが出た。

`self.content.body.to_s`を実行するとhtmlの状態で表示された。これを引数に渡す。

raiseメソッドについては以下。
- [module Kernel (Ruby 3.2 リファレンスマニュアル)](https://docs.ruby-lang.org/ja/latest/class/Kernel.html#M_FAIL)

errosについて
- [ActiveModel::Errors](https://api.rubyonrails.org/classes/ActiveModel/Errors.html)

何故か例外を発生さたときのメッセージをつけるとエラーになる。今はメッセージをなくして対応する。

疑問は、[Rubular: a Ruby regular expression editor](https://rubular.com/)
での動作内容とrailsおよびirbの動作が違うことだ。rails側で想定通りの挙動となっているので現状問題ないが、違うということを注意しないといけない。

改行を含む場合のテストを作成できた。以下に示す。

```ruby
  #作成に失敗するパターン２　タグに囲まれた、空白と改行（&nbsp;と<br>)
  test "space text test" do
    #禁止のパターンを複数列挙する。
    invalid_inputs = [ "<div> \n</div>","<div> </div>","<div> &nbsp; </div>","<div> <br> </div>"  ]

    #Array.eachのブロックパラメータの２つ目は毎回nilになる。
    invalid_inputs.each do |value,space_text|
      assert_raises(ActiveRecord::RecordInvalid) do
        space_text = ChatText.create! content: value
      end
      assert_not space_text, "create!にも関わらずfalseでない。バリデーションが間違っています。"
    end
  end
```
テストも問題なく通った。

疑問があるので少し続ける。

書き方がだめという点と、create!で失敗したときの挙動の理解が間違っている。以下再認識。

1. create!→失敗時の返却値はなし。例外が発生する。すなわち代入は行われない。
1. create →失敗時の返却値は、保存前、すなわちnewして作成されるオブジェクト。例外は発生しない。故に代入は行われる。

また以下の点もポイントである。
1. create  は new + save とほとんど同じ。
1. create! は new + save!とほとんど同じ。

上記はポケットリファレンスにも書かれている。しかし厳密には挙動が違う。以下の違いがある。

1. create の成功時はオブジェクトが返り値、失敗時はsave前のオブジェクトが返り値になる。
1. create!の成功時はオブジェクトが返り値、失敗時は返り値なしで例外が発生する。
1. save   の成功時はtrueが返り値、失敗時はfalseが返却値
1. save!  の成功時はtrueが返り値、失敗時は例外が発生し返り値はなし。

そのためsaveとcreateを勘違いすると以下の間違いが発生する。

```ruby
#以下は正しい
x = ModelName.new
if x.save
  puts "success"
else
  puts "failed"
end

#以下は誤り
if ModelName.create
  puts "success"
else
  puts "failed"
end
#以下のif文も誤り
if x.save!
if x.create!
```

理解が曖昧だったが、おおよそ以下の認識にすると上手く行くだろう。

1. ifで分岐したい→new + saveでsaveの結果を使う。
1. 例外で処理したい→new+save!またはcreate!で処理する。

上記を意識してテストを書き直す。

また、ChatTextの検証では失敗時に！の有無に関わらず例外が発生する。例外が発生するのは！のときのみがいい。どうすればいい？
- [ActiveModel::Validations::ClassMethods](https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validate)

上記にはバリデーションを発生するメソッドを指定するための`:on`オプションがあるそうだ。ではバリデーションが発生するメソッド一覧はどれだろうか？

- [ Active Record バリデーション - Railsガイド](https://railsguides.jp/active_record_validations.html)

上記によれば以下のメソッドでバリデーションが実行されるそうだ。

- create
- create!
- save
- save!
- update
- update!

そのため!つきとそうでないに分けて実装する。

---
小ネタ：  
nokogiriのrequireが必要か疑問だった。以下参考。
- [なぜRuby on Railsではrequireを実施なくてよいのか｜うぃるどん ぶろぐだどん](https://blog.wyrd.co.jp/2022/04/01/%E3%81%AA%E3%81%9Cruby-on-rails%E3%81%A7%E3%81%AFrequire%E3%82%92%E5%AE%9F%E6%96%BD%E3%81%AA%E3%81%8F%E3%81%A6%E3%82%88%E3%81%84%E3%81%AE%E3%81%8B/)
- [ Rails の初期化プロセス - Railsガイド](https://railsguides.jp/initialization.html)

上記によれば、Gemfileに記述すればrequireを記述しなくていいという感じ？Gemfileに追加していたのでコメントアウトしても問題なく動作した。

---

また、!なしのバリデーション失敗についてはerrorsに追加すれば勝手に拾ってくれそうだ。そのためerrors.addを実行しエラーを追加する。

認識を改めたテストコードは以下。

```ruby
  #作成に失敗するパターン２　タグに囲まれた、空白と改行（&nbsp;と<br>と\n)
  test "space text test" do
    #禁止のパターンを複数列挙する。
    invalid_inputs = [ "<div> \n</div>","<div> </div>","<div> &nbsp; </div>","<div> <br> </div>"  ]

    invalid_inputs.each do |value|
      assert_raises(ActiveRecord::RecordInvalid) do
        ChatText.create! content: value
      end
      space_text = ChatText.new content: value
      assert_not space_text.save, "正しく作成されました。バリデーションが間違っています。"
    end
  end
```

　上記までで、通常のモデルのテストはOKだと思う。一度作業内容をコミットしておく。

##### 2.4.4 UserRoomモデル
　ここからは中間テーブルのテスト。

いぜん、中間テーブルのバリデーションはvalidates_associatedでできると思っていた。以下に示す。

- [ Active Record バリデーション - Railsガイド](https://railsguides.jp/active_record_validations.html#validates-associated)
- [valid?｜ActiveRecord::Validations](https://api.rubyonrails.org/classes/ActiveRecord/Validations.html#method-i-valid-3F)

　しかし、これを読んでいると、関連するテーブルを保存するときに関連先のバリデーションをするというものらしい。今のコードの場合、ユーザやルームは事前に登録している。また、action cableで書いた処理自体もチャットテキストを保存してからアソシエーションを解決する順序で実行している。そのためこの方法はあまり意味がない。むしろ、登録しようとするidが存在するかどうかをチェックする方が重要である。そのためChatTextと同様に独自にバリデーションを追加するのが良いと思う。

レコードが存在するかはexists?メソッドがよいと思う。以下参考。
- [ActiveRecord::FinderMethods](https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-exists-3F)

---

小ネタ：  
テストに関する参考は以下。
- [Railsのテストランナー｜Rails テスティングガイド - Railsガイド](https://railsguides.jp/testing.html#rails%E3%81%AE%E3%83%86%E3%82%B9%E3%83%88%E3%83%A9%E3%83%B3%E3%83%8A%E3%83%BC)  
疑問だった、`-n`が動作しない点。どうやら接頭辞として`test_`をつけてスペースを`_`に変えた状態でないと認識されないようだ。

---

UserRoomモデルに空を許可しないバリデーションを記述した。しかし下記がなくとも空白は許可されなかった。これはマイグレーションファイルの影響だと思う。そのため特に記述は必要なさそうだ。

```ruby
  #バリデーションを追加
  validates :user,
    presence: true  #空を許可しない。
  validates :room,
    presence: true  #空を許可しない。
```

以下のメソッドが便利だと思った。
- [find_or_initialize_by｜ActiveRecord::Relation](https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-find_or_initialize_by)

中間テーブルの設定や検証のために使えるかも。このメソッドでモデルのインスタンスをnewするか、レコードが存在すればfindしてくれる。  
→~~作った後で思ったが、今の場合だとfindでいいかもしれない。なぜならコンソールで確認したが、findは見つからない場合はnilが返ってくるからだ。~~  
この点は後のリファクタリングで修正する。

---

追記：  
再確認したところ、User.find(100)とした結果nilは返らず例外が発生した。  
nilが返るのは、find_by(id: 100)であった。  
また、where(id: 100)とした結果、空の配列が返ってきた。

上記の違いがあることに注意したい。

---

ひとまずUserRoomの検証はOKとする。

##### 2.4.5 Chatモデル
　こちらも同様の内容でバリデーションを追加する。  
→ひとまずOK。挙動自体は問題ない。テスト項目もクリアできている。

##### 2.4.6 action cableのテスト
　action cableのテストを行う。テストは２種類。

1. connection test
1. room channel test

それぞれ実行する。  

そのまえにモデルテストでcreate!に関する理解が深まった。action cableにも一部含まれているので修正する。モデルのコードと連携しているところもあるので修正する。  
→!をつけて例外で拾うようにする。

　テストを書いていき、上手く行かないことがある。以下、コントローラではクッキーを以下のように設定した。
```ruby
#connection_test.rb
cookies[:user_info] = {value: @user.id}
cookies[:room_info] = {value: @room.id}
```

しかしテストでは上記のように書くとアクセスできなくなる。しかし以下のように書くとエラーがなくなる。

```ruby
cookies[:user_info] = @user.id
cookies[:room_info] = @room.id
```

このソールで確認するとブラウザでアクセスると文字として1が、テストで表示すると数字として1が出た。そのため文字列に変換すると上手く行く？  
→変化なし。そのため今の所問題なく動作しているのでこのまま続行する。ちなみに、テストスクリプトの初めに書かれているものは、クッキーに直接数値を代入している。そのためテスト内ではそのまま代入するので問題ないのだろうか？

- [cookies()｜ActionCable::Connection::TestCase::Behavior](https://api.rubyonrails.org/v7.0.4/classes/ActionCable/Connection/TestCase/Behavior.html#method-i-cookies)
- [ActionController::Cookies](https://api.rubyonrails.org/v7.0.4/classes/ActionController/Cookies.html)

いろいろ試して理解を深めていく。

コネクションテスト、チャネルテストに共通して、connection（ApplicationCable::Connectのインスタンス）が存在する。これを経由してコネクションの情報にアクセスできる。  
例えば、クッキーで設定した情報を元に認証に成功しているか？など。

コネクションテストは比較的簡単？理由はconnection.rbの記述量が少ないから。やっていることはクッキーからユーザとルームを取得して認証できるか確認するくらいだ。そのためテスト自体も単純だと思われる。

以下にコネクションの動作確認をしたテストを示す。単純だが、connectionというものがあるとわかったのが大きい。
```ruby
  #まずコネクションについて知る
  test "learning connection" do
    @user = User.find_by(user_name: "nkun")
    @room = Room.find_by(room_name: "nkun")
    cookies[:user_info] = @user.id
    cookies[:room_info] = @room.id
    #テスト前にコネクトを実行する。
    connect
    p connection
    p connection.current_user
    p connection.current_room
    assert_instance_of ApplicationCable::Connection, connection, "Connectionのインスタンスではありません。"
    assert_equal @user, connection.current_user, "ログインしているユーザと異なります。"
    assert_equal @room, connection.current_room, "送信されたルームと異なります。"
    disconnect
  end
```

###### 2.4.6.1 action cableのテスト connection test
　コネクションテストで確認すべきは、正しい条件の場合、認証情報を正しく取得できるか？そうでない場合、エラーを正しく発生するか？それだけだと思われる。早速ためす。

コードに誤りを発見。修正。findとfind_byの失敗時の挙動が違った。

失敗時のエラーは以下の通り。

```ruby
ActionCable::Connection::Authorization::UnauthorizedError: ActionCable::Connection::Authorization::UnauthorizedError
```

- [ActionCable::Connection::Authorization](https://api.rubyonrails.org/classes/ActionCable/Connection/Authorization.html#method-i-reject_unauthorized_connection)
- [ActionCable::Connection::Assertions](https://api.rubyonrails.org/v7.0.4/classes/ActionCable/Connection/Assertions.html)

２つ目が重要。`assert_reject_connection`で`reject_unauthorized_connection`で発生したエラーを拾うことができる。  
→OK。エラーをひらえた。

---

小ネタ：  
ブロックを空の状態で実行すると通常はエラーになる。なぜなら、nilクラスにcallメソッドがないので。  
そのためボッチ演算子(&.)を使用するとブロックを空でメソッドを実行してもエラーがでなくなる。

しかし、railsは空の状態で渡してもエラーにならなかった。気になるがボッチ演算子にして挙動が変になることはないと思うのでリファクタリングのときに修正する。

---

###### 2.4.6.2 action cableのテスト room channel test
　チャネルテストで確認すべきことをまず検討する。チャネルの役割はコネクションよりも広いと思われる。チャネルは以下の項目に関わりがある。

1. サブスクリプション（切断時も）
1. チャネル
1. ブロードキャスト

コネクションはコネクションのみだと思うが、チャネルは違うと思う。そのためテストする範囲も比較的広いと思われる。  
(そう思った根拠として、connection.rbはメソッドとして基本的にconnectとdisconnectしかない。channelはroom_channel.rbにsubscribeやbroadcastを記述したメソッドがあるので総判断した。)


- [ActionCable::Channel::TestCase](https://api.rubyonrails.org/v7.0.4/classes/ActionCable/Channel/TestCase.html)
- [ActionCable::Channel::Base](https://api.rubyonrails.org/v7.0.4/classes/ActionCable/Channel/Base.html)

コネクションのときのコネクションに対応するインスタンスはconnectionであった。対してchannelに対応するインスタンスは`subscription`と`transmissions`である。また、`connection`も使える。これらを使うとより理解を深めることができそうだ。

サブスクリプションの中身をみる。
```
#<RoomChannel:0x00007f6e11cfacc0 
@connection=#<ActionCable::Channel::ConnectionStub:0x00007f6e11d9e578 
@transmissions=[{"identifier"=>"test_stub", "type"=>"confirm_subscription"}], 
@subscriptions=#<ActionCable::Connection::Subscriptions:0x00007f6e11cef410 
@connection=#<ActionCable::Channel::ConnectionStub:0x00007f6e11d9e578 ...>, 
@subscriptions={}>, 
@identifiers=[], 
@logger=#<ActiveSupport::Logger:0x00007f6e11cee290 
@level=0, 
@progname=nil, 
@default_formatter=#<Logger::Formatter:0x00007f6e11cee6a0 
@datetime_format=nil>, 
@formatter=#<ActiveSupport::Logger::SimpleFormatter:0x00007f6e11cee1f0 
@datetime_format=nil, 
@thread_key="activesupport_tagged_logging_tags:15060">, 
@logdev=#<Logger::LogDevice:0x00007f6e11cee588 
@shift_period_suffix=nil, 
@shift_size=nil, 
@shift_age=nil, 
@filename=nil, 
@dev=#<StringIO:0x00007f6e11ceead8>, 
@binmode=false, 
@mon_data=#<Monitor:0x00007f6e11cee538>, 
@mon_data_owner_object_id=15020>>>, 
@identifier="test_stub", 
@params={}, 
@defer_subscription_confirmation_counter=#<Concurrent::AtomicFixnum:0x00007f6e11cfa950 value:0>, 
@reject_subscription=nil, 
@subscription_confirmation_sent=true, 
@_streams=["room_channel"]>
```

当然のことだったが間違えていた。subscribeする前にconnectionの設定をしないといけなかった。

レンダリングの結果を整理する。ブラウザからみると上手く行っているのでそちらからとってくる。
```
<div class='chat_box'>
  <div class='user_box'>
      nkun
      2022-12-28 09:20:19 UTC
  </div>
  <p>
    <div class="trix-content">
      <div>動作確認</div>
    </div>
  </p>
</div>
```

よくみるとpタグが不要に見える。修正する。

見え方が変わったが、html要素をみるとtrix-contentというクラスのスタイルを変更するといいだろう。今はテストと関係ないので無視する。

一度この段階でChromeからアクセスしてみる。  
→クッキーとjavascripが無効なので許可すると問題なく動作した。

transmissionsがわからない。

`ActionCable.server`というインスタンス？がある。インスタンスかどうか調べる。  
→`ActionCable::Server::Base`のインスタンスだそうだ。以下をテストして確かめた。

```ruby
assert_instance_of ActionCable::Server::Base, ActionCable.server
```
`ActionCable::Server::Base`のメソッドの中で重要なのは以下。
- [ActionCable::Server::Broadcasting](https://api.rubyonrails.org/v7.0.4/classes/ActionCable/Server/Broadcasting.html)

ブロードキャストしたにもかかわらずtransmissionsにメッセージがたまらない。

一度ActionCable.serverの中身を表示する。

```ruby
#<
  ActionCable::Server::Base:0x00007fc9db3efd80 
  @config=#<
    ActionCable::Server::Configuration:0x00007fc9db3b0ae0 
    @log_tags=[], 
    @connection_class=#<
      Proc:0x00007fc9db3b8060 /home/general_user/.rbenv/versions/3.1.2/lib/ruby/gems/3.1.0/gems/actioncable-7.0.4/lib/action_cable/engine.rb:46 (lambda)
    >, 

    @worker_pool_size=4, 
    @disable_request_forgery_protection=false, 
    @allow_same_origin_as_host=true, 

    @logger=#<
      ActiveSupport::Logger:0x00007fc9db293950 
      @level=0, 
      @progname=nil, 
      @default_formatter=#<Logger::Formatter:0x00007fc9db296218 @datetime_format=nil>, 
      @formatter=#<
        ActiveSupport::Logger::SimpleFormatter:0x00007fc9db293838 
        @datetime_format=nil, 
        @thread_key="activesupport_tagged_logging_tags:14440"
      >, 
      @logdev=#<
        Logger::LogDevice:0x00007fc9db296060 
        @shift_period_suffix="%Y%m%d", 
        @shift_size=1048576, 
        @shift_age=0, 
        @filename="/home/general_user/rails_dir/log/test.log", 
        @dev=#<File:/home/general_user/rails_dir/log/test.log>, 
        @binmode=false, 
        @mon_data=#<Monitor:0x00007fc9db295fc0>, 
        @mon_data_owner_object_id=4420
      >
    >, 

    @cable={"adapter"=>"test"}, 
    @mount_path="/cable", 
    @precompile_assets=true>, 

    @mutex=#<Monitor:0x00007fc9db3efb00>, 

    @pubsub=#<
      ActionCable::SubscriptionAdapter::Test:0x00007fc9d9ce5298 
      @server=#<ActionCable::Server::Base:0x00007fc9db3efd80 ...
    >, 

    @logger=#<
      ActiveSupport::Logger:0x00007fc9db293950 
      @level=0, 
      @progname=nil, 
      @default_formatter=#<Logger::Formatter:0x00007fc9db296218 @datetime_format=nil>, 
      @formatter=#<
        ActiveSupport::Logger::SimpleFormatter:0x00007fc9db293838 
        @datetime_format=nil, 
        @thread_key="activesupport_tagged_logging_tags:14440"
      >, 
      @logdev=#<
        Logger::LogDevice:0x00007fc9db296060 
        @shift_period_suffix="%Y%m%d", 
        @shift_size=1048576, 
        @shift_age=0, 
        @filename="/home/general_user/rails_dir/log/test.log", 
        @dev=#<
          File:/home/general_user/rails_dir/log/test.log
        >, 
        @binmode=false, 
        @mon_data=#<Monitor:0x00007fc9db295fc0>, 
        @mon_data_owner_object_id=4420
      >
    >, 
    @subscriber_map=nil
  >, #ここまでconfig

  @worker_pool=nil, 
  @event_loop=nil, 
  @remote_connections=nil
>
```

ブロードキャストしてもトランスミッションにはたまらない？以下。

```ruby
  assert_broadcast_on("room_channel", { content: "<div>test message</div>" }) do
    ActionCable.server.broadcast("room_channel", { content: "<div>test message</div>" })
  end
```

このテストは成功する。つまり、ブロードキャストで`{ content: "<div>test message</div>" }`というデータをストリームに流すことはできている。

そのため、疑うべきはストリームで止まっている点。ストリームからチャネルにデータが流れていないのが問題だろうか？

- [ActionCable::TestHelper](https://api.rubyonrails.org/v7.0.4/classes/ActionCable/TestHelper.html)

ではテスト上でどのようにストリームからチャネルにデータを送信できるのだろうか？

挙動を調べるとアクションは問題なく動作しているようだ。そのためモデルのインスタンスの生成も、レンダリングもブロードキャストもできる。

transmissionsが謎だが、テスト自体に問題は今の所ない感じがする。なぜならブロードキャストで補足できるからである。もしかするとチャネルに関する設定が間違っている可能性がある。この点はとりあえずイテレーション1では考慮しないことにする。

エラー時の挙動で修正。ユーザ不明時にテキストだけ保存される。トランザクションを追加して防ぐ。

- [ActiveRecord::Transactions::ClassMethods](https://api.rubyonrails.org/v7.0.4/classes/ActiveRecord/Transactions/ClassMethods.html)
- [ActiveRecord::ConnectionAdapters::DatabaseStatements](https://api.rubyonrails.org/v7.0.4/classes/ActiveRecord/ConnectionAdapters/DatabaseStatements.html#method-i-transaction)

とりあえずテストはOKだと思う。以下を試した

1. 購読されたか？(購読に関する細かい設定をしていないので失敗するケースのテストはなし)
1. ストリームはあるか？
1. ブロードキャストはできるか？
1. レンダリング結果は想定通りか？
1. 認証情報がないとき発言内容は保存されないか？

上記で一通り最低限の確認はできたはずだ。

また、action cableのテストを書いてモデルテストのIDの指定の仕方を変えるべきだと思ったので修正する。  
→見返すと修正しようと思っていたところが、そこまで悪くなかったのでそのままにする。

この段階で一度コミットしておく。


##### 2.4.7 applicationコントローラ
　一度全体を仕上げるために、単純な例外処理を追加する。

追加するのは、以下。

1. railsの処理（主にビジネスロジック）中のエラー(ActiveRecord::RecordInvalidが主)を拾う500のサーバーエラー。
1. 無効なURLにアクセスした場合に404を返す。

それぞれ、共通として実行するのでデフォルトの404と500を使う。

また、application_controller.rbの用のテストファイルはない。そんため以下を作りながら追加していく。

##### 2.4.8 authsコントローラ

　ここからはコントローラのテストに入っていく。まずは、成功するパターンと認証に成功・失敗するパターンを書く。新規作成の失敗は例外が発生する。

不明点を整理。以下参考。

- [ActiveSupport::Testing::Assertions](https://api.rubyonrails.org/v7.0/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_no_difference)
- [ Rails テスティングガイド - Railsガイド](https://railsguides.jp/testing.html)

1. assert_no_differenceは数値の違い
1. assert_no_changesは数値以外の場合の変化をみる。

ルーティングエラーをわざと起こした場合以下のエラーが出た。

```ruby
Error:
AuthsControllerTest#test_rooting_error:
ActionController::RoutingError: No route matches [GET] "/wrong_path"
    test/controllers/auths_controller_test.rb:96:in `block in <class:AuthsControllerTest>'
```

上記の、エラーをアサーションでまず対応する。

```ruby
    #例外をテスト側で対応
    assert_raise(ActionController::RoutingError) do
      get wrong_url = root_url+"wrong_path"
      assert_response :missing
    end
```

例外処理を書く。しかし、開発環境では確認できないそうだ。以下参考。
- [ Action Controller の概要 - Railsガイド](https://railsguides.jp/action_controller_overview.html#rescue)

開発環境では常にいつもの赤い画面が出るそうだ。また本番環境でサーバを起動しようとしたっけか以下が出た。

```ruby
Missing `secret_key_base` for 'production' environment, set this string with `bin/rails credentials:edit` (ArgumentError)
```

設定が一部足りていないようだ。そのため現在の優先順位としては低い。ここはイテレーション１以外で対応する。

例外処理自体が、本番環境でしか確認できない感じなので書かないことにする。  
→例外処理は省略する。

例外処理はテスト環境ではどうなるのだろうか？開発環境ではほとんど無効だが、テストだと違うかもしれない。

assert_responseの:missingがルーティングエラーで補足できない。しかし例外が出ているので間違ってはいない。

もう少し調べる。公式リファレンスだけだと難しいのでもう少し幅を広げて調べる。
- [【Rails】 envメソッドで環境を確認する方法と各コマンドの指定方法｜Pikawaka](https://pikawaka.com/rails/env)
- [ApplicationControllerでStandardErrorをrescue_fromするときに少しでも開発しやすく - Qiita](https://qiita.com/ledsun/items/ba11bd7ffecf81084eac)

`Rails.env`というものが重要のようだ。

以下を試す。

```ruby
  rescue_from ActionController::RoutingError do |e|
    #render 'public/404', status: 404
    puts "rescue test" if Rails.env.test?
  end
```

今は開発環境であるため例外処理は後回しにする。まず全体を仕上げることを優先する。

例外処理は以下を予定とする。

---

また、例外が出るエラーはRailsのエラー画面が表示されてしまう。その画面ではユーザは操作できなくなるため、例外処理を加えユーザが継続して操作できるようにする。

現在想定しているエラーは以下でありそれれぞれ次のように対応する。

|エラー|発生条件|対応|
|-|-|-|
|サーバーエラー|無効な入力などによって発生する|500を返す。|
|ルーティングエラー|想定していないURLにアクセスする|404を返す。|

---

合間にrescue_fromについて調べておく。

##### 2.4.9 roomコントローラ
　すべて認証下で実行される。認証が失敗するパターンはすでに検証済みであるため、今回はすべて認証成功下で検証する。  
→一応失敗も書いた。そこまで大変ではなかったので。  
→ただクッキーの方は難しい。そのためクッキーに変な値を入れるというよりは、クッキーの値が正しいということを他の値と比較する。

上記でテストがかけた。テスト項目にクッキーが抜けていたので念の為追加。テスト結果もOK。

上記まででコントローラテストは完了とする。

##### 2.5 ドキュメント作成と抜けの確認
　上記までの内容をドキュメントに書いていくが、抜けが結構見つかる。その分を追加していく。

UserRoomの値の組み合わせが唯一であるという制約をつけていなかった。その点を追加する。

上記の観点からみると先日作ったテストは一部間違っている。合わせて修正する。  
→新しく自分で処理を書く。

手動でテストをした。その結果以下がわかった。

1. ログイン→ログアウト→ブラウザバックで再認証を要求
1. ログイン→ルーム一覧を表示→マイページ→ログアウト→ブラウザバック→再アクセス可

これは困る。この点を修正しないといけない。

以下を確かめた。
- ログイン→ルーム一覧を表示→ブラウザバック→ログアウト→ブラウザバック→再認証

一度ルームに入ってもブラウザバックすれば挙動はおかしくなくなる。以下参考

- [Rails tips: Railsでブラウザキャッシュを削除する - Qiita](https://qiita.com/sausagedog/items/d96f48f34f93f922954c)
- [【Rails】[戻る]ボタンを押すとJSのコードが画面に表示されて画面遷移が正常にされない場合の対処法 - Qiita](https://qiita.com/keisuke-333/items/547947d44cf595313862)
- [Cache-Control - HTTP｜MDN](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Cache-Control)

どうやら以下を記述するのがいいらしい
```ruby
response.headers["Cache-Control"]="no-cache"
```

上手く行かない。

以下参考。

- [Basic認証 Digest認証 Form認証の違い - ITを分かりやすく解説](https://medium-company.com/http%E8%AA%8D%E8%A8%BC%E6%96%B9%E6%B3%95%E3%81%AE%E7%A8%AE%E9%A1%9E%E3%81%A8%E9%81%95%E3%81%84/)
- [ログアウト機能の目的と実現方法｜徳丸浩の日記](https://blog.tokumaru.org/2013/02/purpose-and-implementation-of-the-logout-function.html)

Basic認証ではまずログアウト機能がないそうだ。その理由として認証情報がブラウザ側に残っているのが要因らしい。

そのため、ブラウザ側に残っているのであればjavascriptで消せるのではないか？と思った。そのためその方向で検証する。

しかし、時間がかかるので先に一通り書く。

一度コミットしておく。その後コード、主にビューファイルを修正していく。

ドキュメントを追加した。ログアウトの件がすこし問題だとまとめていて思った。ことログアウトに関してはBasic認証以外のほうが楽に実装できるかもしれない。しかしこれも経験としてやっておいて損はないので良しとする。

この段階で開発本体とドキュメントをコミットする。またイテレーション１はこれで完了とするのでこの記録もここで止める。次のイテレーションの記録に移る。