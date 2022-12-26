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

### イテレーション1 試行錯誤
---
イテレーション1でのコードの内容や[プロトタイプ]({{site.baseurl}}/iteration_1/prototype)で得られた結論に至る過程を知る必要があれば以下を読み進めることを推奨する。不要の場合は非常に長いため読まないことを推奨する。

以下作業記録である。作業中のわからないこと、知ったこと、記録しておくべきと感じたことを知見として記録することを目的とする。

#### 0. 開始コマンドメモ
　以下のコマンドを実行してプロジェクトを作成する。
```bash
rails new . -B --css=sass
```
　sassを使う理由は、通常のcssより便利に開発できるからである。Bootstrapやtailwindを採用しない理由は本件はバックエンド側の作り込みを重視するので見た目はあまり考えない。そのためできるだけ簡素なcssを自分で書いていく。しかし前述の通りcssはプログラムのコードとしては書きにくいため、書きにくさを解消するsassがよいと思い導入した。　　

#### 1. ログイン
##### 1.1 機能の分解
　要求される機能をより分解して小さくし、問題として扱いやすくする。要求されている項目をそれぞれ分解すると以下のとおりである。

画面は以下の4つ。
1. ログイン情報登録画面
1. ログイン画面
1. ログイン成功画面
1. ログイン失敗画面

機能は以下の4つ。
1. ログイン情報を登録する。
1. ログイン情報（ユーザ名、パスワード）をもとに認証する。
1. ログインに成功すれば成功の画面、失敗すれば再ログインの画面を表示する。
1. ログアウトする。

##### 1.2 MVCパターンの検討
　ログイン機能に必要なMVCについて検討する。MVCについてそれぞれ以下のように導入すれば後からの拡張に対応も可能で良いと考えた。

|MVC|内容|
|-|-|
|M|user model class、chat model class、room model class|
|V|ログイン情報登録画面、ログイン画面、ログイン成功画面、ログイン失敗画面|
|C|auth controller class、room controller class|

また、上記のうち
1. user model class、chat model class、auth controller class、room controller class、room model classのクラス図
1. Userテーブル(user model class)とChatテーブル(chat model class)、Roomテーブル（room model class）のER図

についてはクラス図とER図で詳細に設計する。ビューはコードを実装する際に適宜実装を行っていく。

　なおER図はUMLの一種ではない。しかしデータベースの設計をする場合、ER図を使用したほうが効果的に設計できると判断した。そのため本件ではデータベース設計にはER図導入することにした。  
　また、本件でのUMLおよびER図の書き方については、
[UML及びER図の書き方]({{site.baseurl}}/uml_docs)で言及しているため、必要に応じて参照していただきたい。

##### 1.3 ER図
　前述のモデルの仕様に基づいて必要な属性と主キー及び外部キーについて検討した。以下にER図を示す。

|![User Chat Room UserRoom のER図]({{site.baseurl}}/assets/images/user-chat-room-relation.png)|
|:-:|
|図1 ログイン機能のER図|

　モデルになかったUserRoomテーブルが新しく追加されている。これは可視性を示すルームのRoomテーブルとユーザを特定するUserの関係における多対多を解決するための中間テーブルである。ToDoやひとり言にRoomが必要か？であるが、ユーザ名とルーム名が同一の場合ToDoやひとり言を使えるようにするためにこのように作成した。

　また、設計の後で知ったことだがrailsでは複合主キーの使用は良くないそうだ。そのため今回はあくまで概念的に複合主キーを捉えて実装する。すなわち真の主キーは一つ（id)だが、id以外を用いることでid自体を特定することができるように考えて実装するということである。  
　そうなるとER図の修正が必要になるが今は試行錯誤中であること、概念的に捉えた場合上図のほうが都合がいいためそのままにする（試行錯誤後の設計図は更新する)

##### 1.4 画面遷移について
　ログインに関して作る画面は以下の4つ。

1. ログイン情報登録画面
1. ログイン画面
1. ログイン成功画面
1. ログイン失敗画面

　上記の画面の移動に関して整理する。画面遷移については状態遷移図を使用して整理すれば良いと考えたた。そのため、状態遷移図による画面遷移について以下に示す。

|![ログイン画面に関する画面遷移について]({{site.baseurl}}/assets/images/login_view_transition.png)|
|:-:|
|図2 ログイン操作のための画面遷移図|

　以上のMVCパターン、ER図、画面遷移を元に試作を行う。クラス図およびルーティングについてはソースコードを作成しながら検討したほうが効果的に開発できると考えたため後回しにする。

##### 1.5 authコントローラ、userモデルの作成とログイン機能の実装
###### 1.5.1 authコントローラの生成  
　authコントローラの生成は単純に以下のコマンド
```bash
./bin/rails g controller auth
```
これでRailsの標準の認証を実装する。Railsには標準の認証以外にgemがある以下にリンクを示す。
- [https://github.com/heartcombo/devise](https://github.com/heartcombo/devise)  

　このgemを使えば非常に便利に認証を実装できるが、内容を見ていくとあまりに設計からかけ離れすぎるため今回は使用しない。（今回の内容にはあまりに高級な機能ばかりで手に余るというのが正直なところ）

　まずは、参考にしている本を元に簡単に実装する。

ルーティングを設定して表示しようとしたが上手くいかない。一度削除する。
```bash
./bin/rails destroy controller auth
```
以下の生成コマンドを使用する。
```bash
./bin/rails g controller auth login logout
```
　RESTfulなルーティングを考えたとき、認証の場合リソースは認証情報である。しかし認証情報は安易に表示してはいけないし、安易に更新されては困る。あくまで認証後に実行されるべき内容である。そのためそういった制約加える必要がある。CRUDでいえば、認証前にできるのはCくらいであり、それ以外のRUDはすべて認証後に実行可能にすべきである。そのためコントローラに対応するルーティング自体は`resource`とし制約を加える。またCRUD以外の動作であるログイン・ログアウトも加える。これらはRESTfulなルーティングではないが、必要な処理であるため、`resource`のメソッドに追加して対応をする。

　一応CRUDの対応と追加の内容としては以下である。

|CRUD + login logout|処理|
|-|-|
|C|アカウント作成|
|R|アカウント情報表示|
|U|アカウント情報更新|
|D|アカウント情報削除|
|login|ログイン（認証を検証)|
|logout|ログアウト（認証成功状態を破棄）|

そのため、上記の通り認証に関するURLはRESTfulにしたほうがきれいに設計できる。しかし認証のためのURLも追加しなければ上手く機能しない。

railsの命名規則の把握が甘かった。参考は以下。
- [Rails それぞれの命名規則をまとめみた](https://qiita.com/pank24ever/items/b3698c400d7a5fb59914)

再度生成したファイルを削除。

```bash
./bin/rails destroy controller auth
```
以下の生成コマンドを実行
```bash
./bin/rails g controller auths login logout
```
コントローラは複数形。本だと単数だったので不注意だった。

###### 1.5.2 user modelの生成

以下のコマンドを実行
```bash
./bin/rails g model user user_name:string password:string
```
`user_id`についてはmodel生成時に自動で生成される`id`を用いる。  
上記実行後はデータベースを作成する。以下を実行する。
```bash
./bin/rails db:create
./bin/rails db:migrate
```
users.ymlにテストデータ（３人のユーザ情報を仮に作成）を記述してデータベースに流し込む。
```bash
./bin/rails db:fixtures:load
```
コンソールに入って確認。
```bash
./bin/rails c
> User.all
  User Load (0.6ms)  SELECT "users".* FROM "users"
=>                                                     
[#<User:0x00007fb7a6177180                             
  id: 1,                        
  user_name: "nkun",            
  password: "[FILTERED]",       
  created_at: Fri, 02 Dec 2022 15:23:55.421366000 UTC +00:00,
  updated_at: Fri, 02 Dec 2022 15:23:55.421366000 UTC +00:00>,
 #<User:0x00007fb7a61770b8      
  id: 2,                        
  user_name: "xsan",            
  password: "[FILTERED]",       
  created_at: Fri, 02 Dec 2022 15:23:55.421366000 UTC +00:00,
  updated_at: Fri, 02 Dec 2022 15:23:55.421366000 UTC +00:00>,
 #<User:0x00007fb7a6176ff0
  id: 3,
  user_name: "ysan",
  password: "[FILTERED]",
  created_at: Fri, 02 Dec 2022 15:23:55.421366000 UTC +00:00,
  updated_at: Fri, 02 Dec 2022 15:23:55.421366000 UTC +00:00>]
```
passwordのFILTEREDが気になるがひとまずOKとする。  
実際にログインしてみたら問題なく動作した。ログイン自体はOK。次は情報の登録画面について。

###### 1.5.3 新規登録
　新規登録のためにビューを作成した。scafflodで作られた形を参考に部分的に実装していく。今回は、使用するモデルとコントローラの名前が違うため少し厄介な点があるが、その点はあまり難しくなかったため問題ではない。

　しかし、コードを書いているときに実行しているコードが正しいか検証しにくいためテストを書いて行こうと思う。プロトタイプなのでテストを書かずに実現可能性だけ検証しようとしたがテストを書いたほうが楽になりそうだったためそうする。  
そのためまずテスト用のデータベースを作成する。以下を実行。
```bash
./bin/rails db:test:prepare 
```

またテストの実行は以下のように実行する。
```bash
./bin/rails test test/controllers/auths_controller_test.rb
```
また、自動生成されるテストコードが何故か失敗するので修正する。（urlヘルパーの書き順が何故か逆になっていた）

コントローラの機能テストについてはRailsガイドにまとめられていた。以下に示す。

- [ Rails テスティングガイド - Railsガイド](https://railsguides.jp/testing.html#%E3%82%B3%E3%83%B3%E3%83%88%E3%83%AD%E3%83%BC%E3%83%A9%E3%81%AE%E6%A9%9F%E8%83%BD%E3%83%86%E3%82%B9%E3%83%88)

コントローラのテストは機能テストというらしい（モデルテストではない）。上記などを参考にテストを書いて検証していく。またはデバッグコードを入れて確かめる。

postメソッドで使われる`param`がよくわからない。まずテストコード自体の書き方が不明だったのでますコンソールで確かめる。コンソール上で以下を実行すると、まず`get`できることがわかった。
```ruby
./bin/rails c -s
irb(main):006:0> app.get 'http://172.17.0.2:3000/auths'
Started GET "/auths" for 127.0.0.1 at 2022-12-04 07:47:15 +0000
  ActiveRecord::SchemaMigration Pluck (0.5ms)  SELECT "schema_migrations"."version" FROM "schema_migrations" ORDER BY "schema_migrations"."version" ASC 
Processing by AuthsController#show as HTML
  Rendering text template
  Rendered text template (Duration: 0.0ms | Allocations: 9)
Completed 200 OK in 5ms (Views: 1.6ms | ActiveRecord: 0.0ms | Allocations: 1926)  
=> 200   

irb(main):007:0> p app.auths_path
"/auths"
=> "/auths"

irb(main):008:0> app.get '/auths'
Started GET "/auths" for 127.0.0.1 at 2022-12-04 07:50:13 +0000
Processing by AuthsController#show as HTML
  Rendering text template
  Rendered text template (Duration: 0.1ms | Allocations: 4) 
Completed 200 OK in 3ms (Views: 2.2ms | ActiveRecord: 0.0ms | Allocations: 215) 
=> 200

irb(main):009:0> app.get app.auths_path
Started GET "/auths" for 127.0.0.1 at 2022-12-04 07:52:20 +0000
Processing by AuthsController#show as HTML                                              
  Rendering text template
  Rendered text template (Duration: 0.1ms | Allocations: 4) 
Completed 200 OK in 2ms (Views: 1.4ms | ActiveRecord: 0.0ms | Allocations: 167)
=> 200
```
何故か上記が毎回成功するわけではないのが謎である。`app.get 'http://172.17.0.2:3000/auths'`を実行した後だと上手く行くようだ。そのためホストなどの設定を見直しておいたほうがいいかもしれない。しかしテストファイルに書いて実行すれば上手く行く。例えば以下。
```ruby
    get auths_url
    assert_response :success
```
上記をテストすると成功する。なのでコンソールではなくテストとして実行する上では設定の変更は必要ない。

また、Basic認証のあるコントローラのテストはRailsガイドのコントローラの機能テストの項目に書いていた。その内容は以下のリンクの書いていることであった。
- [ActionController::HttpAuthentication::Basic](https://api.rubyonrails.org/v6.0.2.2/classes/ActionController/HttpAuthentication/Basic.html)

上記を参考に以下のようにテストを書いた。
```ruby
  #paramsの検証（フォームの送信内容)
  test "params method check" do
    post auths_url , headers: { Authorization: ActionController::HttpAuthentication::Basic.encode_credentials("nkun","password")}
    assert_response :success
  end
```
テストを実行すると以下が表示された。
```bash
./bin/rails test test/controllers/auths_controller_test.rb:17
...
Error:
AuthsControllerTest#test_params_method_check:
ActionController::ParameterMissing: param is missing or the value is empty: user
    app/controllers/auths_controller.rb:51:in `user_info'
    app/controllers/auths_controller.rb:22:in `create'
    test/controllers/auths_controller_test.rb:18:in `block in <class:AuthsControllerTest>'
```
今まではテストコードに関するエラーが表示されていたが、やっとコントローラの内容に関するエラーが表示された。これでデバックコードを仕込めばparamsの内容が見えるはずだと思う。

paramsの表示を以下に変えて観察する。
```
  def user_info
    pp params #.require(:user).permit(:user_name, :password)
  end
```
その結果以下の出力を得た。
```bash
#<ActionController::Parameters {"controller"=>"auths", "action"=>"create"} permitted: false>
#<ActionController::Parameters {"controller"=>"auths", "action"=>"create"} permitted: false>
```
userの情報が入っていない。この点を修正すれば解決できそうだ。

paramsの書き方が良くなかった。いかに修正したところテストは通った。
```ruby
post auths_url , params: {user: {user_name: 'nkun', password: 'password'}}
```
と思っていたが、本質的なところは`new`アクションで新しくインスタンスが生成されていなかった。その点を修正したところ、userのハッシュが生成された。

また、テストが通るようになってから他のコントローラの修正をした。

ログインしたときにアカウント情報が維持されてしまうときは以下を参考にしてクッキーを削除する。
- [キャッシュと Cookie の消去](https://support.google.com/accounts/answer/32050?hl=ja)  

ユーザ名を間違えたときの挙動がおかしい。どうにもエラーが出る。内容は以下。
```ruby
if @user.password.eql?(pw)
undefined method `password' for nil:NilClass
```
しかしこの前に以下の処理を入れている。
```ruby
      # ユーザ名に該当するユーザを検索（同一名のユーザは許容しないとする) 
      @user = User.find_by(user_name: name)
      # ユーザがいなければ失敗を返す
      if @user.nil?
        render 'show'
      end
```
と思ったが、returnしていないので当然だった。returnを入れてこの時点で終了する。  
→上手く行った。

しかしユーザの情報が正しく入力された場合にはセッションを維持してほしいが、そうでないときに維持されると困る。そのためクッキーの設定を見直す。（ほかを優先するのでこれはあくまで予定）  
または、認証が失敗するという想定のテストを書くべきだろうか？（今はプロトタイプ段階なのでできるだけテストは書きたくないので優先順位を落として考える。）


###### 1.5.4 ログアウト
上記まででセッションの維持の制御はできていない（現状強制的に維持状態である）が、一応以下の機能はできた。

1. ログイン&ログイン成功画面へ遷移
1. 新規登録＆登録後にログイン成功画面へ遷移

故に画面遷移の観点では残りはログアウトとそれに伴う画面遷移、ログイン失敗画面の準備（これはログイン画面をベースに作るのでそこまでかからない？）である。まずはログアウトから作る。

ログアウトはデータベース上にはアカウント情報を維持し、セッションだけを破棄する。となると先延ばしにしていたセッションの維持についても調整しなければならないと思う。  
また、ログイン済みの状態でログイン画面を開いたときの挙動について検討し漏れていた。ログイン情報を保持していた場合、ログイン画面と登録画面にアクセスできないようにし、直接ログイン成功画面を表示するようにする。（ログインヘルパー？という形にして実装することになるだろうか？）

- ログイン情報の保持

　ruby on rails 7 ポケットリファレンスを読んでいるとデフォルトではセッション情報はクッキーに保存されるそうだ。しかしパスワードなどの機密情報はクッキーに保存するべきではないそうだ。そのためセッション情報は`session`を使用して作る。`session`はデフォルトではクッキーに保存される。しかし設定によってクッキー以外に保存することができるようになる。そのため作り方としては、まずは`session`を使用して実装し、その後クッキー以外に指定する方法を考えた。その順序で実装可能性を検討する。

　まずはログアウトへのリンクをつけて、`get`メソッドで遷移したに直接`/auths`に遷移する（`show`メソッドを呼び出した遷移する）。これを実装すればログアウトのための土台ができるはず。  
　ログアウトのメソッドを`logout`に書き込んでいく。

　セッションに情報を書き込む。効率よくハッシュを扱うためにセッションを書き込むメソッドを書く。以下の通り。
```ruby
  #セッションの設定
  def set_session hash_list={}
    hash_list&.each do |key,value|
      session[key]=value
    end
  end
```
これを使えば以下のように`session`にデータを書き込める。
```ruby
  set_session user_name: name, password: pw
```
また、以下のようにセットするとエラーが出た。
```ruby
  @user = User.find_by(user_name: name)
  set_session user: @user
```
Userクラスの情報がハッシュとして保存されている？
```ruby
undefined method `user_name' for {"id"=>1, "user_name"=>"nkun", "password"=>"password", 
"created_at"=>"2022-12-05T08:32:27.546Z", "updated_at"=>"2022-12-05T08:32:27.546Z"}:Hash
  '.freeze;@output_buffer.append=( @user&.user_name );@output_buffer.safe_append='
```
また、Userクラス本体は以下の形をしている。
```ruby
#<User id: 1, user_name: "nkun", password: [FILTERED], created_at: "2022-12-05 15:19:38.510540000 +0000", updated_at: "2022-12-05 15:19:38.510540000 +0000">
```

原因が現状不明だが、ひとまずセッション経由で変数を渡した場合はハッシュになるという理解で作っていく方が良いかもしれない。(応急処置的な対応だが現状の最適解はこれとする。)  
→ 後日の追記：ハッシュを`new`演算子に渡してインスタンスを生成するとハッシュをインスタンスとして再生成できた。  
→ 後日更に追記：ポケットリファレンスを読んでいるとp.101の下部に説明があった。セッションにオブジェクトを保存すると内部的にシリアライズされる。おそらく私がいま経験している現象はシリアライズに相当すると考えられる。そのため`new`演算子で再構成するというのはオブジェクトとして扱いやすくするという意味では間違いではないと思われる。

しかし、ログアウトメソッドでセッションを破棄しても上手く行かない。ブラウザ側での動作を確認してみる。  
以下参考。
- [Authorization - HTTP ](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Authorization)

リクエストヘッダを確認したところ以下が書かれていた。
```
Basic bmt1bjpwYXNzd29yZA==
```
いまはbasic認証で実装しているため平文でログイン情報が保存されているはずだがよくわからない形になっている。以下参考。
- [Base64 - MDN Web Docs 用語集 ウェブ関連用語の定義](https://developer.mozilla.org/ja/docs/Glossary/Base64)

base64という符号化らしい。rubyでないか調べてみた。以下に示す。
- [module Base64 (Ruby 3.1 リファレンスマニュアル)](https://docs.ruby-lang.org/ja/latest/class/Base64.html)

あったのでirbで試してみる。
```ruby
irb(main):072:0> require 'base64'
=> true
irb(main):073:0> puts Base64.decode64('bmt1bjpwYXNzd29yZA==')
nkun:password
=> nil   
```
簡単にデコードできた。
[Authorization - HTTP | MDN](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Authorization)
によれは書式は以下の通りらしい。
```
user_name:password
```
なので間違ってはなさそうだと思う。しかしどこに保存されているのだろうか？(特に設定していないのでクッキーだろうか？)

セッション維持の処理を以下のように実装してみた。
```ruby
  #ログイン状態でのみアクセスを許可するように処理する。
  def keep_login?
    #セッション内にユーザ情報を保持し（別メソッドで）、セッション情報を元にログイン状態を維持する。
    #セッションからユーザ情報を取り出す。
    user_login = User.new session[:user]
    p user_login
    unless user_login.user_name&.nil?
      #ユーザ情報がある場合、認証を試みる。
      keep_auth = http_basic_authenticate_or_request_with(name: user_login.user_name, password: user_login.password, realm: 'Application')
    else
      #セッション内にユーザ情報がない場合、リダイレクトor描画を許可しない。
      return false
    end
  end
```
これを記述し、`mypage`にアクセスする前に実行するように設定した。この状態で以下のテストを実行した。（ユーザは作成済みとする）
```ruby
  #認証
  test "keep session check" do
    #ログインする
    get login_auths_url , headers: { Authorization: ActionController::HttpAuthentication::Basic.encode_credentials("nkun","password")}
    assert_response :redirect
    #リダイレクトに成功したらその先を確認する。
    get mypage_auths_url
    assert_response :success
    #ログアウトしてセッション情報を確認する
    get logout_auths_url
    assert_response :redirect
    #ログアウトした先を表示する。
    get auths_url
    assert_response :success
  end
```
上記のテストコードはセッション維持のコードを導入する前は成功することを確認している。しかし、導入後は以下のエラーが出て失敗する。
```ruby
Failure:
AuthsControllerTest#test_keep_session_check [/home/general_user/rails_dir/test/controllers/auths_controller_test.rb:32]:
Expected response to be a <2XX: success>, but was a <401: Unauthorized>
Response body: HTTP Basic: Access denied.
```
セッションの内容に間違いがあると思い情報を表示。
```ruby
#<User id: 1, user_name: "nkun", password: [FILTERED], created_at: "2022-12-06 05:59:16.826000000 +0000", updated_at: "2022-12-06 05:59:16.826000000 +0000">
"start auth"
"nkun"
"password"
F
Failure:
AuthsControllerTest#test_keep_session_check [/home/general_user/rails_dir/test/controllers/auths_controller_test.rb:32]:
Expected response to be a <2XX: success>, but was a <401: Unauthorized>
Response body: HTTP Basic: Access denied.
```
ログインの情報はセッションにきちんと格納されていた。しかし認証には失敗する。単純に使用するメソッドが間違っているのだろうか？

テストを以下にすれば通るようになった。
```ruby
    #リダイレクトに成功したらその先を確認する。
    get mypage_auths_url , headers: { Authorization: ActionController::HttpAuthentication::Basic.encode_credentials("nkun","password")}
    assert_response :success
```
そのため、単純に`keep_login`でリクエストヘッダに認証情報を送信できてないことになる。そのためリクエストの設定をする。

以下のようにすればリクエストヘッダにユーザ情報を付与できるはずだ。
```ruby
request.headers['Authorization'] = ActionController::HttpAuthentication::Basic.encode_credentials(user_login.user_name,user_login.password)
```
実際テストには成功している。しかし気になるのは以下の内容。
テストコードだが以下が不明。
```ruby
  #認証に失敗させる
  test "failed authorization" do
    #間違えたパスワードを入力する。
    get login_auths_url , headers: { Authorization: ActionController::HttpAuthentication::Basic.encode_credentials("nkun","matigatteruyo")}
    #失敗を期待する
    assert_response :unauthorized
  end
```
参考は以下
- [ActionDispatch::Assertions::ResponseAssertions](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/ResponseAssertions.html)
- [rails/response.rb at 8015c2c2cf5c8718449677570f372ceb01318a32 · rails/rails · GitHub](https://github.com/rails/rails/blob/8015c2c2cf5c8718449677570f372ceb01318a32/actionpack/lib/action_dispatch/testing/assertions/response.rb#L30)
- [rack/utils.rb at main · rack/rack · GitHub](https://github.com/rack/rack/blob/main/lib/rack/utils.rb)

しかし、結果は以下の通り。
```ruby
Failure:
AuthsControllerTest#test_failed_authorization [/home/general_user/rails_dir/test/controllers/auths_controller_test.rb:45]:
Expected response to be a <401: unauthorized>, but was a <302: Found> redirect to <http://www.example.com/auths>
Response body: <html><body>You are being <a href="http://www.example.com/auths">redirected</a>.</body></html>.
Expected: 401
  Actual: 302
```
なお、`302`は`Found`らしい。なので認証には成功している。コントローラの設定が間違っているのだろうか？

認証については以下を参考。
- [WWW-Authenticate-HTTP｜MDN](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/WWW-Authenticate)
- [HTTP 認証 - HTTP｜MDN](https://developer.mozilla.org/ja/docs/Web/HTTP/Authentication)

となると気になるのは認証に使っている`authenticate_or_request_with_http_basic`だと思う。これは仕様をほとんど気にせずに実装していたのでまずはこれをしらべて理解を深めるのが良いと感じたからである。このメソッドが何を返すか不明であるため詳しく調べる。

---
長くなるので一度区切る。

`authenticate_or_request_with_http_basic`について
- [rails/http_authentication.rb at 8015c2c2cf5c8718449677570f372ceb01318a32 · rails/rails · GitHub](https://github.com/rails/rails/blob/8015c2c2cf5c8718449677570f372ceb01318a32/actionpack/lib/action_controller/metal/http_authentication.rb#L92)

上記を読んでいくと以下のように分解できる。
```ruby
  def authenticate_or_request_with_http_basic(realm = nil, message = nil, &login_procedure)
    authenticate_with_http_basic(&login_procedure) || 
    request_http_basic_authentication(realm || "Application", message)
  end
```
上記の中身は以下の２つ。
```ruby
  def authenticate_with_http_basic(&login_procedure)
    HttpAuthentication::Basic.authenticate(request, &login_procedure)
  end

  def request_http_basic_authentication(realm = "Application", message = nil)
    HttpAuthentication::Basic.authentication_request(self, realm, message)
  end
```
`||`で上２つはつながっている。そのため１つ目が真であれば１つ目の戻り値が返るので先に１つ目を調べる。
```ruby
  def authenticate(request, &login_procedure)
    if has_basic_credentials?(request)
      login_procedure.call(*user_name_and_password(request))
    end
  end
```
上記は105行目にある。一応以下にリンク。
- [rails/http_authentication.rb at 8015c2c2cf5c8718449677570f372ceb01318a32 · rails/rails · GitHub](https://github.com/rails/rails/blob/8015c2c2cf5c8718449677570f372ceb01318a32/actionpack/lib/action_controller/metal/http_authentication.rb#L105)

そのため`has_basic_credentials?`、`*user_name_and_password`でできている。
```ruby
  def has_basic_credentials?(request)
    request.authorization.present? && (auth_scheme(request).downcase == "basic")
  end

  def user_name_and_password(request)
    decode_credentials(request).split(":", 2)
  end
```
- [rails/http_authentication.rb at 8015c2c2cf5c8718449677570f372ceb01318a32 · rails/rails · GitHub](https://github.com/rails/rails/blob/8015c2c2cf5c8718449677570f372ceb01318a32/actionpack/lib/action_controller/metal/http_authentication.rb#L111)
- [rails/http_authentication.rb at 8015c2c2cf5c8718449677570f372ceb01318a32 · rails/rails · GitHub](https://github.com/rails/rails/blob/8015c2c2cf5c8718449677570f372ceb01318a32/actionpack/lib/action_controller/metal/http_authentication.rb#L115)

１つ目は、認証情報が`basic`かつ、`request.authorization.present`であること。  
２つ目は、認証情報を`:`で２つに分けて、２つに分けた結果を配列にして返す。

```ruby
  def auth_scheme(request)
    request.authorization.to_s.split(" ", 2).first
  end
```
`request`の内容が不明。スペースで分けられたもののうち１つ目を取り出す。  
```ruby
  # Returns the authorization header regardless of whether it was specified directly or through one of the proxy alternatives.
  def authorization
    get_header("HTTP_AUTHORIZATION")   ||
    get_header("X-HTTP_AUTHORIZATION") ||
    get_header("X_HTTP_AUTHORIZATION") ||
    get_header("REDIRECT_X_HTTP_AUTHORIZATION")
  end
```
- [rails/request.rb at 8015c2c2cf5c8718449677570f372ceb01318a32 · rails/rails · GitHub](https://github.com/rails/rails/blob/8015c2c2cf5c8718449677570f372ceb01318a32/actionpack/lib/action_dispatch/http/request.rb#L404)

訳すとおおよそ以下の通り。
> 認可ヘッダが直接指定されたか、プロキシの代替手段を介して指定されたかに関わらず、認可ヘッダを返す。

そのため`authorization`は認可ヘッダ（authorization header）を返す。
これについては、前に示した[Authorization - HTTP | MDN](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Authorization)に書かれている。

`authorization`で以下の内容が得られると予想する。
```
<type> <credentials>
```
上記の結果を受けて、`auth_scheme`で`<type>`を取得（今回だと`basic`）する。  
あくまで推測だが、`decode_credentials(request).split(":", 2)`は符号化された`ユーザ名:パスワード`をもとに戻して、`:`で分割して２要素の配列にして返していると考えられる（それ故に*user_name_and_passwordとして引数に入れられていると思う)

`get_header`まで掘り下げるとやり過ぎだと思うので、今はヘッダー情報を取得すると捉えて単純化する。  
→と思ったが掘り下げないとわからないことがあったので以下に示す。
```ruby
  def get_header(key);    headers[key];       end
```
- [rails/response.rb at 8015c2c2cf5c8718449677570f372ceb01318a32 · rails/rails · GitHub](https://github.com/rails/rails/blob/8015c2c2cf5c8718449677570f372ceb01318a32/actionpack/lib/action_dispatch/http/response.rb#L179)

`headers`の中身が必要。

`headers`が不明。調べると複数あるが一番有力そうなものを以下に示す。
```ruby
  def headers
    @headers ||= Http::Headers.new(self)
  end
```
- [rails/request.rb at 8015c2c2cf5c8718449677570f372ceb01318a32 · rails/rails · GitHub](https://github.com/rails/rails/blob/8015c2c2cf5c8718449677570f372ceb01318a32/actionpack/lib/action_dispatch/http/request.rb#L210)
- [rails/headers.rb at 8015c2c2cf5c8718449677570f372ceb01318a32 · rails/rails · GitHub](https://github.com/rails/rails/blob/8015c2c2cf5c8718449677570f372ceb01318a32/actionpack/lib/action_dispatch/http/headers.rb#L24)

`headers`の中身は`Http::Headers`クラスのインスタンスだと思われる。ハッシュ的にヘッダにアクセスできるが、返る値が不明。`string`とか`integer`であればいいが。（`authentication`をみる感じだとあっている可能性が高いように見える、またポケットリファレンスを読んでいる感じもそうだと思う）。この点をどう調べればいいか不明なので一度放置する。

今まで書いてきた処理を考えると、`authenticate`で主に処理していると考えられる。しかし認証に成功した場合と失敗した場合の表示が不明。  
→ポケットリファレンスを読み返すと、ブロックの戻り値の`true`or`false`で認証の成否が決まるそうだ。
そのため、ヘッダーに情報を送るかどうかを考えるのではなく、正しく`true`or`false`を判定すればいいだけらしい。

上記までで得られた情報を元に考えたところ、`authenticate_or_request_with_http_basic`の認識が変わった。

このメソッドは入力フィールドを表示してその上で認証するわけではない。あくまでリクエストヘッダの情報をデコードしてその上で認証しようとする。そしてその可否は自分で制御できる。  
そのため前述のテストが失敗しないのは自分のコードの書き方の問題であり、その問題の箇所はログインプロシージャの書き方である。ヘッダ情報にユーザ名とパスワードを付与する方法は間違えていない。このメソッドはヘッダ情報を元に認証するのでむしろこの方法を取れば、このメソッドを呼び出しつつ、入力エリアを出さない挙動を実現できるかもしれない。

---
ひとまず下調べは以上。
少しだけ`authenticate_or_request_with_http_basic`に関する理解が深まったと思う。

とりあえず、現状のコードの末尾にfalseを追加して強制的に認証を失敗させる。
以前まで成功していたテストを実行した。以下の結果を得た。
```ruby
Failure:
AuthsControllerTest#test_keep_session_check [/home/general_user/rails_dir/test/controllers/auths_controller_test.rb:29]:
Expected response to be a <3XX: redirect>, but was a <401: Unauthorized>
Response body: HTTP Basic: Access denied.
```
OK。`<401: Unauthorized>`が出たので認証に失敗している。ログインプロシージャの戻り値が認証の可否を表すため戻り値の制御をしっかりとする。

ステータスコードは以下に示されている。
- [rack/utils.rb at main · rack/rack · GitHub](https://github.com/rack/rack/blob/main/lib/rack/utils.rb)

コードを書いていると認証を含んだ画面遷移の認識が間違っているかもしれない。

---

認証の手順について調べる。

###### httpの認証
[Authorization - HTTP | MDN](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Authorization)
を読み直すと順序について書いていた。通常はまず`unauthorized`を返してから認証するそうだ。

順序については[HTTP 認証 - HTTP | MDN](https://developer.mozilla.org/ja/docs/Web/HTTP/Authentication)
にわかりやすく図として書かれていた。認識は間違っていなそう。`Authorization`ヘッダはサーバに対して認証情報を送信するために使われる。実際rails側の方でも`Authorization`ヘッダに含まれるユーザ名とパスワードを使用して認証する。

図のはじめに見える`WWW-Authenticate`については、[WWW-Authenticate - HTTP｜MDN](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/WWW-Authenticate)に書かれている。また、[rails/http_authentication.rb at main · rails/rails · GitHub](https://github.com/rails/rails/blob/main/actionpack/lib/action_controller/metal/http_authentication.rb#L135)にrailsでのその実装が書かれている。これは`authenticate_or_request_with_http_basic`を構成する２つのメソッドのうちの一つである。`request_http_basic_authentication`は`HttpAuthentication::Basic.authentication_request`で実装されており、`authenticate_with_http_basic`が失敗したときに返される。

図を元に`authenticate_or_request_with_http_basic`を捉え直すと以下のことが推測される。
1. まず`authenticate_or_request_with_http_basic`を呼び出すと`unauthorized`がサーバーから返される。  
その際には`request_http_basic_authentication`が呼び出される。
1. その後、認証情報の入力をユーザに促し、情報を入力する。
1. 入力情報を`Base64`の形式に符号化＆`Authorization`ヘッダを作成しサーバに送信する。
1. サーバは受け取った認証情報を`authenticate_with_http_basic`によってログインプロシージャに渡し認証を実行し成功or失敗を判定する。（この処理は自分で制御できる）
1. 失敗した場合は`unauthorized`(401)を返し、成功した場合は`success`(200)を返す。（成功・失敗の判定は`true`or`false`で決定でき、それらを`authenticate_or_request_with_http_basic`の戻り値とすることで実現できる）

という流れになると予想される。（いろいろとコードを読んだがあくまで推測に過ぎない。断定できない）

追記：ブラウザ側で認証の手順を確認してみた。認証のリンクに飛ぶとリクエストするコンテンツが`unauthorized`で認証に失敗している状態だった。その状態で認証情報を求めるポップアップが出ていた。そのため少なくとも上記手順のはじめの挙動はあってそうだ。そして認証情報を入力した後に`Authorization`のリクエストヘッダがある状態でステータスコードが`OK`の200としてコンテンツが表示されていた。railsの中身の処理については推測に過ぎないが、それ以外に関しては認識に間違いはなさそうだと感じる。しかし問題は認証に失敗するようにしているにも関わらず認証に成功していることだ。ここは書き方が間違っているはずなのでしっかりと修正する。

---

現在の状態に戻ってこれるように一度作業内容をコミットする。

前述までの下調べで認証に関する認識が変わった。自分としてはログインのための処理とログイン状態の維持の処理は別だと思っていた。しかし、`session`を使用することでそれらを同一のものとして扱うことができるのではないかと考えた。

そう思って再度作ってみる。  
重要なのは、`session`を使用してログインを維持すること。そうしないとログアウトできなくなるから（と思っている）。

疑問なのはブラウザでどのようにログイン情報を保持し、認証メソッドに渡しているか？現状わかっていない。  
そのため、まずはセッションの保存について制御してみる。まずはクッキーのままで有効期限をとても短くしてセッションが切れるようにしてみる。

rubyでの時間の表現方法がわからない。調べたところ以下のサイトがわかりやすくまとめられていた。
- [【完全網羅】RubyのTime使い方まとめ｜侍エンジニアブログ](https://www.sejuku.net/blog/16204)
- [rails/calculations.rb at 4-2-stable · rails/rails · GitHub](https://github.com/rails/rails/blob/4-2-stable/activesupport/lib/active_support/core_ext/date_and_time/calculations.rb)

まずは開発環境で設定をする。`config/enviroments/development.rb`に以下を追加する。
```ruby
  #セッション管理
  config.session_store :cookie_store
  config.session = {
    expire_after: 1.seconds
  }
```
しかし上手く行かない。以下の書き方に修正するとクッキーの挙動が変わった。
```ruby
  #セッション管理
  config.session_store :cookie_store, expire_after: 1.seconds
```
ブラウザでアクセスして少し時間がたつとクッキーが消えた。しかし認証情報が消えたわけではなさそうだ。実際にリクエストヘッダを確認すると`Authorization`ヘッダが消えていない。クッキーにセッション維持情報を記述している設定なのに消えていない。一度クッキー以外を指定してみる。
```ruby
  #セッション管理
  config.session_store :cache_store, expire_after: 1.seconds
```

アクティブサポートについて調べた。以下に記す。
- [ Active Support コア拡張機能 - Railsガイド](https://railsguides.jp/active_support_core_extensions.html)

以下に記述を変えた。
```ruby
  #セッション管理
  config.session_store :cookie_store, expire_after: 1
```
また、すべてのブラウザを閉じてから再度開くとログイン情報が破棄されていた。そのため調べもののために開くのは`Chrome`として開発として開くのは`Firefox`とする。`Firefox`であれば比較的単純なコマンドでターミナルから開くことができるため、セッション管理の設定周りを作り込むときに便利だと思ったのでそうした。

Firefoxのコマンドライン操作については以下を参考とする。
- [FirefoxとLinuxコマンドライン](https://wowgold-seller.com/ja/stories/6193-firefox-and-the-linux-command-line)

例えば以下のように実行する。
```bash
firefox http://172.17.0.2:3000/auths
```
ブラウザを閉じると（アプリケーション本体を閉じる）、と認証情報が破棄されるようになった。設定は以下の通り。
```ruby
  #セッション管理
  config.session_store :cache_store, expire_after: 100
```
上記の設定をみると、認識が正しければキャッシュに100秒間セッションが維持されるためブラウザを認証状態で閉じても100秒以内で再アクセスすると認証できるはず？と思っていたがそうではないのだろうか？（何が正しいかわからない）。

ひとまずセッション管理の上記コードはコメントアウトしておく。

調べていくと以下のサイトを見つけた。
- [Basic認証のキャッシュを削除する（ログアウトする）｜ DevelopersIO](https://dev.classmethod.jp/articles/delete-cache-for-basic-authentication/)

しかしこの内容を実行してもキャッシュが消えない。と思ったが、  
ヘッダを確認すると`Authorization`の部分がちゃんと書き換わっていた。キャッシュが消えていないように見えるのは今、検証用に必ず認証が成功するように設定しているからであった。上記のサイトの方法を取れば一度強制的にログアウトできそうだ。

また、上記のサイトを読むとログアウトの意味合いが変わってきたと思う。ログアウトは認証情報の破棄だと思っていた。しかし、無効なユーザ名とパスワードで認証することでセッション情報を上書きしログインできないようにするという方法も有効であると思う。そうすればログイン用のメソッドから認証部分をログインメソッドを使用すれば実装できるようになり実装も薄くすることができると思う。

いろいろと試してみたが、空白のユーザ名とパスワードを使用するとユーザ名やパスワードに対して新しい追加もなく実装できそうだと思った。しかし上書きできない可能性があるためなんとも言えない。

上書きできない可能性としては、すでに認証情報のある状態でユーザ名とパスワードの組を`:`としてアクセスした結果、認証情報の上書きが起きなかった。そのため空白は良くない可能性がある。ただ疑問なのはrails側で強制的にヘッダを書き換えた場合はセッションは維持されるのだろうか？少し試してみる。

以下のテストを実行してみる。
```ruby
  #空認証
  test "empty authorization" do
    #適当に入力する。必ず認証に成功するようにしている。
    get login_auths_url, headers: { Authorization: ActionController::HttpAuthentication::Basic.encode_credentials("nkun_janaiyo","matigatteruyo")}
    p request.headers['Authorization']
    assert_response :success
    
    #ユーザ名とパスワードをなしで認証
    get login_auths_url, headers: { Authorization: ActionController::HttpAuthentication::Basic.encode_credentials("","")}
    p request.headers['Authorization']
    assert_response :success
  end
```
結果は以下。
```ruby
"Basic bmt1bl9qYW5haXlvOm1hdGlnYXR0ZXJ1eW8="
"Basic Og=="
```
ある意味当然だが、一応上書きはできるかもしれない。

認証について調べていると以下のサイトを見つけた。びっくりした。
- [HTTP Semantics （日本語訳）](https://triple-underscore.github.io/http-semantics2-ja.html)

普段はMDNのドキュメントを読んでいたが、日本語に翻訳してくださっているものがあるとは知らなかった。重要そうなサイトだと思うので念の為メモする。

認証についてある程度知識が集まってきた。この段階で一度処理の流れについてまとめて行こうと思う。処理の流れはアクティビティ図で書いて、流れを可視化する。

認証についてまとめた。以下に示す。

|![ログイン処理とログアウト処理]({{ site.baseurl }}/assets/images/login_logout_procedure.png)|
|:-:|
|図3　ログインとログアウト|

このようにすることで、認証の経路を一つに絞ることができ、認証の維持も同一の処理で実行できると考えられる。

上図を元にコードを新しく作り直していく。

ルーティングが変わり、URIとメソッドの組をrails側のアクションと紐付ける方法が曖昧であったため調べた。以下に示す。
- [ Active Record の基礎 - Railsガイド](https://railsguides.jp/active_record_basics.html#crud-%E3%83%87%E3%83%BC%E3%82%BF%E3%81%AE%E8%AA%AD%E3%81%BF%E6%9B%B8%E3%81%8D)

しかし、テストなどで使える`get`や`post`がアプリケーション本体で発行することにこだわって考えていたが、認識が間違っていた。というよりも忘れていたのほうが近い。  
すなわちRailsはRESTfulなルーティングを推奨しているためリソースに対してCRUDを意識すると上手く行く。そのためCRUDに対応するメソッドを考えると上手く行くということを忘れていた。

考えていたのはログアウトのためにHTTPメソッドをコードで実装する方法。上記の参考を読むと`update`(CRUDのU)を使用すると上手く行くということだと思う。  
（これを調べるときのキーワードはActiveRecord::Base）  
加えて、以下のブログがヒントになった。
- [rails 発展その6　 n+1問題　HTTPリクエスト一覧とルーティングのコツ　 ActiveRecord::Baseメソッド一覧 - Qiita](https://qiita.com/savaniased/items/72475835a0e9887dbd5c)

ただ疑問はURIとどう紐付けるのだろうか？という点。この点は作っていく過程で調べていこうと思う。  
→色々勘違いをしている。

認証が変だと思ったがどうやら`false`と`return false`は違うようだ。いかに例を示す。
- 失敗例
```ruby
  authenticate_or_request_with_http_basic('Application') do |name, pw|
    return false
  end
および
  authenticate_or_request_with_http_basic('Application') do |name, pw|
    return false if true
  end
```
挙動としては問答無用で失敗するはずが、逆に問答無用で成功する。

- OKな例
```ruby
  authenticate_or_request_with_http_basic('Application') do |name, pw|
    false
  end
または
  authenticate_or_request_with_http_basic('Application') do |name, pw|
    false if true
  end
および
  authenticate_or_request_with_http_basic('Application') do |name, pw|
    status = false
  end
```
どうやら直接returnするのはダメみたい。もしかするとブロックに関する認識が間違っている可能性がある。

調べたところ以下がヒットした。
- [手続きオブジェクトの挙動の詳細 (Ruby 3.1 リファレンスマニュアル)](https://docs.ruby-lang.org/ja/latest/doc/spec=2flambda_proc.html)

これによれば`return`ではなく`next`だった。

```ruby
  authenticate_or_request_with_http_basic('Application') do |name, pw|
    next false if true
  end
```
上記は上手く行った。これで途中で処理を抜けることができそうだ。

また、`authenticate_or_request_with_http_basic`を使っていてわかったことは、明示的に`true`を返さないと認証に成功しないと言うこと。そのため失敗の処理を書くのはいいが逆に成功の処理を書き忘れると永遠に認証に成功しない現象が起きるので注意したい。

なぜか`User.new session[:user]`が失敗する。中身をみるとセッションに入ったときにハッシュになっていなかった。なぜ？以前はハッシュになったのに？  
→単純に`session[:user]`を使う。原因は次に問題が生じたときに考える。

テストを書いて動作を確認。
```ruby
  #認証に失敗させる
  test "failed authorization" do
    #間違えたユーザ名とパスワードを入力する。
    get mypage_auths_url , headers: { Authorization: ActionController::HttpAuthentication::Basic.encode_credentials("nkun_janaiyo","matigatteruyo")}
    #失敗を期待する
    assert_response :unauthorized
  end
  #認証に成功させる
  test "success authorization" do
    #正しい情報を入力する
    get mypage_auths_url , headers: { Authorization: ActionController::HttpAuthentication::Basic.encode_credentials("nkun","password")}
    #成功を期待する
    assert_response :success
  end
```
OK。クリアした。

ログアウトをするためにマイページにログアウトボタンを設置した。
```ruby
<%= form_with model: @user, url: logout_auths_url, method: :post do |f| %>
    <div>
        <%= f.label 'ログアウト' , style: "display: block"%>
        <%= f.submit 'ログアウトはここをクリック'%>
    </div>
<% end %>
```
`logout`メソッドとルーティング設定は以下。
```
$ ./bin/rails routes -c auths
      Prefix Verb   URI Pattern             Controller#Action
logout_auths POST   /auths/logout(.:format) auths#logout
mypage_auths GET    /auths/mypage(.:format) auths#mypage
   new_auths GET    /auths/new(.:format)    auths#new
  edit_auths GET    /auths/edit(.:format)   auths#edit
       auths GET    /auths(.:format)        auths#show
             PATCH  /auths(.:format)        auths#update
             PUT    /auths(.:format)        auths#update
             DELETE /auths(.:format)        auths#destroy
             POST   /auths(.:format)        auths#create
```
```ruby
# ログイン情報を上書き
def logout
  #セッションを破棄する
  request.headers['Authorization'] = ActionController::HttpAuthentication::Basic.encode_credentials("","")
  set_session user: nil
  redirect_to url_for action: 'mypage'
end
```
フォームはデフォルトでHTTPメソッドの`POST`が使用されるはずだが生じるエラーは以下の通り
```
No route matches [PATCH] "/auths/logout"
```
フォームのサブミットボタンを押すと上記のエラーが出る。なぜだろう？まずフォームはデフォルトでPOSTで、設定でPOSTだと明記もしている。またルーティングでもURIパターンとメソッドとコントローラ・アクションの対応もしっかりとしているが、上記のエラーが出る。

そもそもなぜ`PATCH`が出ている？モデルが保存済みだからだろうか？

まずPATCHについて
- [PATCH - HTTP｜MDN](https://developer.mozilla.org/ja/docs/Web/HTTP/Methods/PATCH)

近いメソッドとしては`PUT`だそう。Webを支える技術にはなかったので驚いた（というよりこの本ではメソッドが8つしかないと書いていたが実際はそうではない？バージョンの違い？）。

それ以前に、ログアウトはサーバ側のデータを消す必要はない（セッションだけ消すが）。そのためモデルと紐付いたフォームを作成する必要はないはずだ。そのためモデルの部分を削除する。  
→効果はなかった。

調べたが、今書いているコードに誤りは見られない。そのため素直にルーティングをかえる。`POST`から`PATCH`に変更する。
→エラーは消えたがログアウトできていない。また、ブラウザからみると`PATCH`でなく`POST`になっている。なぜ？またセッションも消えていない。

そもそも、`patch`で認証のヘッダを書き換えることは妥当なのだろうか？変更なしで`patch`すると捉えると妥当？

キャッシュの上書きだが、rails側で一度空白の認証を成功させる必要があるかもしれない。一度そうする。

リクエストオブジェクトについてのリンクがわかったので以下に示す。
- [ActionDispatch::Request](https://api.rubyonrails.org/v7.0/classes/ActionDispatch/Request.html)

空白のユーザ名を使うことでログアウトに似た処理はできた。しかし、ブラウザバックで簡単に再ログインできる。目標はブラウザバックしても再ログインできないようにすることだ。

調べたところブラウザバックを防ぐにはjavascriptを使うしかなさそうだ。（というよりクライアント側の問題なのでjavascriptは必須なのだろう）。サーバ側では難しそうなので次はクライアント側からのアプローチを考えたいと思う。

###### 1.5.5 フロントエンド側の操作
　サーバ側ですべて実装することはできないため、クライアント側で動くjavascriptでの動作は必須だと考えられる。  
フロントエンド側で実装すべきは以下であると考えられる。

|動作|目的|
|-|-|
|ブラウザバックの禁止|ログアウト後にブラウザバックできないようにする。|
|`Authorization`ヘッダの編集|ヘッダ情報を編集できればログアウトの形を変えられる。|

上記は片方が実現できれば不要になるかもしれない。なぜならヘッダが編集できればブラウザバックしても認証が要求されるし、ブラウザバックできなければ再度入口から認証し直す必要があるだけなので（そのままスルーする場合はヘッダの編集が必要）

フロントエンド側の準備として以下の作業をする。
1. pakage.jsonの編集(なぜかjavascriptのビルドコードがなかったので追記)
1. application.html.erbの編集（こちらもjavascriptのリンクタグがない。なぜ？）
1. app/javascript/application.jsの作成&編集（なぜかrails new の段階でなかった。-Bオプションの影響か？）

上記の操作でjavascriptがかける環境ができるはずだ（ポケットリファレンスを読んでいるとそういう感じだと思った）。

1.pakage.jsonの編集
以下を追記
```JSON
"build": "esbuild app/javascript/*.* --bundle --sourcemap --outdir=app/assets/builds"
```

2.application.html.erbの編集
ヘッダに以下を追加。
```ruby
<%= javascript_link_tag "application", "data-turbo-track": "reload", defer: true %>
```
`"data-turbo-track": "reload"`を入れているのでHotwireを有効にするためにjavascript側の設定が必要。

3.app/javascript/application.jsの作成&編集
`app/javascript/application.js`がない。ディレクトリごとない。そのため作成する。  
以下のコマンドを実行する。
```bash
mkdir -pv app/javascript
touch app/javascript/application.js
```
どうやらdocker側でrails newした場合にHotwireが有効になっていないそうだ。Hotwire(厳密にはその中のStimulus)は開発が楽になる機能があるそうなのでできれば有効にしておきたい。  
以下に参考を示す。
- [Hotwire（Turbo）を試す その1: 導入、作成・更新フォーム - Qiita](https://qiita.com/kazutosato/items/10a5bc04443d6b7e5bf8)
- [Rails 7: importmap-railsとjsbundling-railsでのStimulusの扱いの違い｜TechRacho by BPS株式会社](https://techracho.bpsinc.jp/hachi8833/2022_03_04/115430)
- [週刊Railsウォッチ（20210426前編）Hotwireの詳細な解説記事3本、Rails 7に入る予定の機能ほか｜TechRacho by BPS株式会社](https://techracho.bpsinc.jp/hachi8833/2021_04_26/107414)

上記をヒントにGithubなどの情報を探してみる。特に気になるのは１つ目の記事に書いている。`./bin/rails hotwire:install`である。このコマンドについて詳しく知りたい。(結構はじめのbundle installをスキップするデメリットが出ているかもしれない)

hotwireについて調べた。以下に示す。
- [GitHub - hotwired/hotwire-rails: Use Hotwire in your Ruby on Rails app](https://github.com/hotwired/hotwire-rails)

上記をみるとこのgemは非推奨になっている。ざっくりと読むと2つのgemを集約しただけだったのでそれぞれ直接使うほうがいいということらしい。今はturbolinkはあまり使おうとは思っていない(理由は以下)ためstimulusだけ導入してみる。

> [Rails 7.0 + Ruby 3.1でゼロからアプリを作ってみたときにハマったところあれこれ - Qiita](https://qiita.com/jnchito/items/5c41a7031404c313da1f)  
手慣れている方でもtrubolinkは色々と厄介だそうだ。そのため今は無理に導入する必要もないだろう。と思ったが、デフォルトで入るものなので導入しておく。

stimulusは以下。
- [GitHub - hotwired/stimulus-rails: Use Stimulus in your Ruby on Rails app](https://github.com/hotwired/stimulus-rails)

上記によれば以下のコマンドで導入できるそうだ。
```bash
bundle install 
./bin/rails stimulus:install
```
`gem 'stimulus-rails'`は初期から入っているので単純にコマンドを実行する。(おそらくこのコマンドを実行するとapp/javascriptのディレクトリができると思う。)

また、package.jsonをみるとesbuildが入っていないようだった。以下を参考。
- [jsbundling-rails/README.md at main · rails/jsbundling-rails · GitHub](https://github.com/rails/jsbundling-rails/blob/main/README.md)

esbuildをインストールするには以下を実行。その前に追記した箇所を消しておく。
```bash
bundle add jsbundling-rails
./bin/rails javascript:install:esbuild
#以下のエラーみたいなのが出た。
Compile into app/assets/builds
       exist  app/assets/builds
   identical  app/assets/builds/.keep
File unchanged! The supplied flag value not found!  app/assets/config/manifest.js
File unchanged! The supplied flag value not found!  .gitignore
File unchanged! The supplied flag value not found!  .gitignore
```
エラーについては、以前に出たものと同じであるため今回も無視する。

上記コマンドを実行することでapplication.html.erbの編集で追記したもの（よくみると間違ってい）が入った。そのため自分で書いた間違えたものは消しておく。

turboについてもデフォルトで入っているものなので一応入れておこうと思う。以下参考及び作業。
- [GitHub - hotwired/turbo-rails: Use Turbo in your Ruby on Rails app](https://github.com/hotwired/turbo-rails)

```bash
./bin/rails turbo:install
./bin/rails turbo:install:redis
```
`gem "turbo-rails"`ははじめから入っていた。そのためはじめの`bundle install`は実行しなかった。  
上記までの操作で、ホスト側で`rails new .`としたときと同じpackage.jsonの状態になったとはずだ。これではじめに`rails new . -B`としたときに`bundle install`を停止したときにともに停止するものはカバーできたのではないかと考えている。(調べていると hotwire = stimulus + turboなのでそれらをインストールするのがミソだったかもしれない。)

turbo自体の説明やドキュメントは以下の通り
- [HTML Over The Wire｜Hotwire](https://hotwired.dev/#screencast)
- [Turbo Handbook](https://turbo.hotwired.dev/handbook/introduction)

また、stimulusのコントローラの追加などのコマンドについては以下。
- [GitHub - hotwired/stimulus-rails: Use Stimulus in your Ruby on Rails app](https://github.com/hotwired/stimulus-rails#usage-with-javascript-bundler)

以下も一応リンクを記述しておく。
- [jsbundling-rails README（翻訳）｜TechRacho by BPS株式会社](https://techracho.bpsinc.jp/hachi8833/2022_09_21/121895)

バンドラーにesbuildを選択したのは特に何も指定しない限り`esbuild`が選択されるからである。まずはデフォルトで使われているものを使って作る。(厳密にはデフォルトはimportmap-railsだが、cssのフレームワークにsassを今回使用している。その際に自動的にjsbundling-railsが選択される。という認識。)

上記までのコマンドを実行することでフロントエンド側の準備ができたと思う。この状態を保存するために一度コミットしておく。

stimulusのマニュアル、turboのマニュアルは以下の通り。
- [Stimulus Handbook](https://stimulus.hotwired.dev/handbook/introduction)
- [Turbo Handbook](https://turbo.hotwired.dev/handbook/introduction)

turboのwebページのリンクを忘れていた。以下に示す。（わかりやすさのためstimulusも合わせて示す）
- [Turbo: The speed of a single-page web application without having to write any JavaScript.](https://turbo.hotwired.dev/)
- [Stimulus: A modest JavaScript framework for the HTML you already have.](https://stimulus.hotwired.dev/)

英語なので少しハードルが高いが、必要に応じて読んでいく。（無理に自分でハードルをあげない）

また、困ったときは以下のURLを元に検索をするといいと感じる。
- [Hotwire Discussion](https://discuss.hotwired.dev/)

javascriptが使えるようになったので早速書いてみる。せっかく`hello_controller.js`があるので使ってみる。  
`show.html.erb`に以下を追加
```html
<br />
<div data-controller="hello"></div>
```
`hello_controller.js`の中身は以下の通り。デフォルトで生成された内容である。
```js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.textContent = "Hello World!"
  }
}
```
こうするとページの末尾に`Hello World!`と追加された。

いちどここで、stimulusとturboの認識について確認する。現状の認識は以下のとおり。
1. hotwire=stimulus+turboである。またhotwireはSPAを便利に実現する手段の一つである。
1. stimulusはhtmnlを書き換えるのが得意なjavascriptフレームワーク。
1. turboはサーバとデータのやり取りをするのが得意なjavascriptフレームワーク。

すなわち、ページ遷移をせずにhtmlを書き換える仕組み(SPA)として、便利にhtmlを書き換える機能を持つstimulusと、変更内容をサーバと通信して取得するturboであるという認識である。

javascriptが有効になったのが確認できた。そのため以下のことができるか試す。

1. ブラウザバックの禁止
1. リクエストヘッダの編集

作業の途中だが、Googleの検索を便利にするコマンドを作った。
- [GitHub - Nagasaka-Hiroki/ubuntu_shell_script: Ubuntuで使うシェルスクリプトを作る](https://github.com/Nagasaka-Hiroki/ubuntu_shell_script#get_domain_nameget_domain_namesh)  
エイリアスを`dn`とした。これで調べものが効率化できるはず。

1.ブラウザバックの禁止
ブラウザバックを禁止する方法は以下が参考になるかもしれない。
- [JavaScriptでブラウザバックを "ほぼ完全禁止" する方法｜PisukeCode - Web開発まとめ](https://pisuke-code.com/javascript-prohibit-browser-back/)

上記サイトは[開発者向けのウェブ技術｜MDN](https://developer.mozilla.org/ja/docs/Web)を情報源に持ってきているため信頼性が高いと思われる。

javascriptのファイルを追加して上記サイトのものを書いてみた。しかし動かない。

操作内容は以下。
1. app/javascript/logout_page.jsを作成しコードを記述。
1. app/views/auths/logout.html.erbにインクルードタグをつける。
1. 確認  
→動かない。

ポケットリファレンスやエラーを読んでいると、アセットパイプラインの設定がおかしそうだ。現状のアセットパイプラインはデフォルトのSprocketsを使用しているためmanifest.jsファイルの設定が変？以下に示す。
```js
//= link_tree ../images
//= link_tree ../builds
```
また、コマンドで読み込み先のパスを表示できるそうだ。
```irb
irb(main):001:0> Rails.application.config.assets.paths
=> 
["/home/general_user/rails_dir/app/assets/builds",                                                        
 "/home/general_user/rails_dir/app/assets/config",                                                        
 "/home/general_user/rails_dir/app/assets/images",                                                        
 "/home/general_user/rails_dir/app/assets/stylesheets",                                                   
 "/home/general_user/.rbenv/versions/3.1.2/lib/ruby/gems/3.1.0/gems/stimulus-rails-1.2.0/app/assets/javascripts",
 "/home/general_user/.rbenv/versions/3.1.2/lib/ruby/gems/3.1.0/gems/turbo-rails-1.3.2/app/assets/javascripts",
 "/home/general_user/.rbenv/versions/3.1.2/lib/ruby/gems/3.1.0/gems/actiontext-7.0.4/app/assets/javascripts",
 "/home/general_user/.rbenv/versions/3.1.2/lib/ruby/gems/3.1.0/gems/actiontext-7.0.4/app/assets/stylesheets",
 "/home/general_user/.rbenv/versions/3.1.2/lib/ruby/gems/3.1.0/gems/actioncable-7.0.4/app/assets/javascripts",
 "/home/general_user/.rbenv/versions/3.1.2/lib/ruby/gems/3.1.0/gems/activestorage-7.0.4/app/assets/javascripts",
 "/home/general_user/.rbenv/versions/3.1.2/lib/ruby/gems/3.1.0/gems/actionview-7.0.4/lib/assets/compiled"]
```
package.jsonは以下の通り。
```json
  "scripts": {
    "build:css": "sass ./app/assets/stylesheets/application.sass.scss:./app/assets/builds/application.css --no-source-map --load-path=node_modules",
    "build": "esbuild app/javascript/*.* --bundle --sourcemap --outdir=app/assets/builds --public-path=assets"
  }
```
そのためjavascriptファイルのパスは通っているはず。実際application.html.erbにパスを書いたときはきちんと機能している。ブラウザバックボタンを押しても現在のページが維持されていた。

しかし、logout.html.erbにつけたときは挙動が変になっている。試しにnew.html.erbに記述してみたところ問題なく動作した。logout.html.erbに問題がありそう（そもそもgetメソッドで取得していないことが問題か？）

ひとまず、ブラウザバック禁止という目標は達成できた。そのため次の目標に進む。

2.リクエストヘッダの編集
リクエストヘッダの編集をjavascriptでできるかどうか試す。まず下調べ。
- [Forbidden header name (禁止ヘッダー名) - MDN Web Docs 用語集: ウェブ関連用語の定義｜MDN](https://developer.mozilla.org/ja/docs/Glossary/Forbidden_header_name)
- [Headers - Web API｜MDN](https://developer.mozilla.org/ja/docs/Web/API/Headers)

上記のサイトをみる限り、`Authorization`ヘッダは変更はできそう（なぜなら禁止ヘッダ一覧になかったので）。

また、方針を少し変える。サーバ側（rails側）でログアウトの処理をなくそうと思う。なぜなら、ログアウトはブラウザ側に保存されている`Authorization'ヘッダを削除or上書きすることで実現できるからである。しかしログアウトを実行するためのボタンなどの設定はrails側で実装する。

- [フェッチ API - Web API｜MDN](https://developer.mozilla.org/ja/docs/Web/API/Fetch_API)

また、使うメソッドは予想だが上記のフェッチAPIだと思う。似たAPIに[XMLHttpRequest - Web API｜MDN](https://developer.mozilla.org/ja/docs/Web/API/XMLHttpRequest)があるが、これはSPAのためのAPIの印象を受けた。なぜなら、このページの冒頭には以下の記述がある。
> [XMLHttpRequest](https://developer.mozilla.org/ja/docs/Web/API/XMLHttpRequest)  
XMLHttpRequest (XHR) オブジェクトは、サーバーと対話するために使用されます。ページ全体を更新する必要なしに、データを受け取ることができます。これでユーザーの作業を中断させることなく、ウェブページの一部を更新することができます。

ページ間を遷移せずに、現在開いているページでサーバと通信する仕組みを提供してくれるAPIであることが上記でわかる。そのため、現在やりたいログアウトページへの遷移と認証情報の削除or上書きとは目標が違うと考えられる。

サイトを読んでいくと以下を見つけた。
- [フェッチ API の使用#資格情報つきのリクエストの送信 - Web API｜MDN](https://developer.mozilla.org/ja/docs/Web/API/Fetch_API/Using_Fetch#%E8%B3%87%E6%A0%BC%E6%83%85%E5%A0%B1%E3%81%A4%E3%81%8D%E3%81%AE%E3%83%AA%E3%82%AF%E3%82%A8%E3%82%B9%E3%83%88%E3%81%AE%E9%80%81%E4%BF%A1)

またvscodeでjavascriptをデバックすることができるらしい。いかにブログのリンクを貼っておく。
- [VSCodeでJavaScriptのデバッグが容易になったらしい](https://zenn.dev/chida/articles/a12f72ed8153b0)

まずは、webコンソール上で試してみる。
```js
new Request('URL')
```
上記の形で実行すると、入力したURLに合わせたリクエストが出る？`http://172.17.0.2:3000/auths/mypage`のリクエストを作った（ログイン状態で）。
```
Request { method: "GET", url: "http://172.17.0.2:3000/auths/mypage", headers: Headers(0), destination: "", referrer: "about:client", referrerPolicy: "", mode: "cors", credentials: "same-origin", cache: "default", redirect: "follow" }
```
ログアウト状態で作ると以下。
```
Request { method: "GET", url: "http://172.17.0.2:3000/auths/mypage", headers: Headers(0), destination: "", referrer: "about:client", referrerPolicy: "", mode: "cors", credentials: "same-origin", cache: "default", redirect: "follow" }
```
特に変わらない。認証情報の`Authorization`はなかったと思う。変わりに`credentials: "same-origin"`があった。これは[フェッチ API の使用#資格情報つきのリクエストの送信 - Web API｜MDN](https://developer.mozilla.org/ja/docs/Web/API/Fetch_API/Using_Fetch#%E8%B3%87%E6%A0%BC%E6%83%85%E5%A0%B1%E3%81%A4%E3%81%8D%E3%81%AE%E3%83%AA%E3%82%AF%E3%82%A8%E3%82%B9%E3%83%88%E3%81%AE%E9%80%81%E4%BF%A1)にも書かれている内容だった。オリジンというのがよくわからないが、同一ユーザであること仮定するとおおよそ理解できる。

つまり、現在の認証情報と同一でアクセスするということ。そのため認証時には一度失敗する流れで処理されるのだろう。  
と思ったが、どうやら既定値らしい。

アクセスは以下の関数。
- [fetch() - Web API｜MDN](https://developer.mozilla.org/ja/docs/Web/API/fetch)

サーバを起動して以下を試す。
```js
site=new Request('http://172.17.0.2:3000/auths/mypage')
fetch(site);
```
こうすると、認証情報を要求するポップアップが表示された。一歩前進か？

fetch APIに関する認証情報は以下。`Authorization`ヘッダは直接いじれなさそう。
- [Request.credentials - Web API｜MDN](https://developer.mozilla.org/ja/docs/Web/API/Request/credentials)  
この項目の設定をしっかりとやると上手く行くかもしれない。

ログアウトページをgetできるようにして、ブラウザバックしたらアラートを出して禁止するようにする。
- [window.alert - Web API｜MDN](https://developer.mozilla.org/ja/docs/Web/API/Window/alert)

しかしアラートが繰り返して出る。なぜだろう？コンソールにカウントを表示するとイベントは一度ブラウザバックするとイベントが２回起きていることがわかった。これはオプション的な立ち位置なので一度無視する。
また、スクリプトをインクルードしていないページでもブラウザバックが禁止されている。なぜだろう？

また、繰り返しブラウザバックしようとするとエラーが出てブラウザバックできるようになってしまう。  
→これはDos攻撃に関する挙動の可能性がある。こちらに関してはサーバ側で例外を拾うように設定すればいいと思う。（クライアント側での操作はしない）

ブラウザの開発者ツールを見ているとログアウトページにアクセスするとブラウザバック禁止のスクリプトが読み込まれた状態が維持されている。これを削除できればいいのだが。
(履歴を消すのも有りだろうか？)
→リロードをして対策？

認証情報の設定の制御がRequestオブジェクトで制御できるか？

- [location.href－JavaScriptリファレンス](http://www.htmq.com/js/location_href.shtml)

location.hrefは現在のページのURLを返す。  
location.replace()は括弧の中のURLにリダイレクトする。

- [Window: load イベント - Web API｜MDN](https://developer.mozilla.org/ja/docs/Web/API/Window/load_event)
- [location.reload() - Web API｜MDN](https://developer.mozilla.org/ja/docs/Web/API/Location/reload)

あまりにログアウトの実装に手間取りすぎているので直接ログアウトの実装について調べる。

- [Basic認証で強制ログアウトさせて、再認証プロンプトを表示させる - Qiita](https://qiita.com/rf_p/items/4b3b62284b65331fb5f2)

調べた中だと上記が最も近いかもしれない。意外と自分が考えていたことに近いと思うので、書いている内容を参考に実装してみる。

基本方針は同じ。キャッシュの上書きを無効なユーザ情報で行う。直接情報の破棄はできないので上書きするというながれ。それを具体的にやっているのが上記のサイト。　　
これを読むとおおよそ次をやっている。
1. ログイン状態にする
1. 無効なユーザ情報を付与して再認証
1. わざと失敗して情報を上書き
1. 同じ画面に再遷移してサーバにアクセス
1. 認証情報を破棄しているので認証に失敗
1. 認証情報の再入力が促される→ログアウト完了

やろうとしていたことと完全に一致している。しかし、この方法ではログアウト前の画面が表示されっぱなしになると思う。それであればrails側で実現できていた。しかし画面の遷移（ログアウト後の画面）と認証情報の破棄が同時にできない。サーバ側で実装すると認証情報がのこる（つまりブラウザバックで再ログインできてしまう）。そのためクライアント側で実装しようとしたがどうなのだろうか。試してみる。  
（クライアント側で処理するという試みは、初心者でたどり着いたのはいい結果だと思う）  
→ただ試してみるとサーバ側で実装できた。以下に示す。

コードを見直すとかなりいいところまで来ていると思った。（javascriptの知識をおいすぎたかもしれない）。以下に実装していた内容で惜しいところを上げていく。
1. サーバ側で空認証が実装済み（空白の情報で認証）。その内容がログアウト画面で起こしている。
1. ビューにログアウト画面へのリンクをつけている。

上記ビュー内のリンクに無効なユーザ情報で認証をわざと成功させればいいと思った。  
すなわち、空認証ではなく偽認証という方がただしいかもしれない。注意すべきはそれをデータベースに登録しない、登録できないようにするのが重要。（そういう意味では空認証の方が楽)
rubyでランダムな文字列を発生させ、それを偽認証情報として使用し偽認証を成功させるようにする。
```irb
irb(main):001:0> require 'securerandom'
=> true
irb(main):002:0> p SecureRandom.alphanumeric
"WT5CZXGqkwLuv05D"
=> "WT5CZXGqkwLuv05D"
```
- [module SecureRandom (Ruby 3.1 リファレンスマニュアル)](https://docs.ruby-lang.org/ja/latest/class/SecureRandom.html)

これでログアウトはできた。調べて方針が正しいと確信できてからはとても早かった（やりたいことはほとんどサーバ側で実装できた）。しかし、以下の順序だと変な挙動になる。
1. ログイン→成功→マイページを表示。(ログイン画面とマイページはこの後は認証情報の入力なしで反復可)
1. ログアウトボタンでログアウト→ログアウト画面を表示。
1. ログアウト画面でブラウザバック→認証情報の入力が要求（正しい情報を入力で戻れる）
1. マイページに戻った後で、ブラウザフォーワード？（ブラウザバックのバック、つまり矢印でログアウト画面を要求）したときに、偽認証の認証情報を要求される。

上記の現象はあまり起きない、起きたとしてもあまり問題でないと思うので一度無視する。必要に応じて対処する。

ちなみに空認証だと上手く行かない。上手く上書きできない。

おうよそログインとログアウトについてはできたと思う。

反省すべきは、これにかなり時間を割いたことだ。しかしrailsの知識もフロントエンドの知識もいつもより意識的に入ってきたので今後の効率を考えると良かったかもしれない。  
しかし、必要以上に興味に突き動かされていたのでその点はしっかりと制御したい。

追記：  
少し修正。createメソッドでクラスインスタンス変数？(@usrとか)が使われていたので修正。しかし`@`を取り除いて実装するとエラーが出た。
```
SQLite3::ReadOnlyException: attempt to write a readonly database 
```
調べたところ以下がヒットした。
- [SQLite3::ReadOnlyException: attempt to write a readonly databaseへの対応 - Qiita](https://qiita.com/eitches/items/4836dd261ba8ec8de444)

単純に権限の問題orデータベースの作り方の問題の可能性がある。データベースの作り方の手順を見直す。
```bash
./bin/rails db:migrate:reset
./bin/rails db:fixtures:load
```
あまり変化がなかった

解決したのはユーザ名とパスワードに空白が入っているかどうかだった。空白は不可らしい。

残った問題はフォワードの問題。ブラウザバックの逆として考えれば可能かもしれない。ユーザのご操作を防ぐためあったほうがいいかもしれないが、あくまでも作り込み要素として考えておく。

##### 1.6 ルーティング
　コードを作りながら以下のルーティングを決定した。下記のルーティングは画面遷移図と一致しない。そのため画面遷移図も修正を加える。修正後はここでは示さず最終的な設計のまとめに示す。

|URL|http method|controller#action|表示内容・動作内容|
|-|-|-|-|
|/auths|GET|auths#show|ログイン・アカウント作成の選択。|
|/auths|POST|auths#create|新規アカウントの発行。|
|/auths/new|GET|auths#new|新規アカウント作成画面を表示。ユーザ名とパスワードを入力して`/auths`に`POST`する。その後mypageにリダイレクトするが、リダイレクトのURLにユーザ名をつけている。|
|/auths/logout|GET|auths#logout|ログアウト画面に移動する。偽の認証情報を付与しており、ログアウトするようにしている。|
|/auths/mypage|GET|auths#mypage|ログインが必要な画面。フィルタとして認証処理をつけている。|

##### 1.7 下調べリスト
　上記までの中の重要なリンクをまとめる。一部重複があるかもしれないがまとめとして示す。
- [ActionController::HttpAuthentication::Basic::ControllerMethods](https://api.rubyonrails.org/classes/ActionController/HttpAuthentication/Basic/ControllerMethods.html)
- [ Rails テスティングガイド - Railsガイド](https://railsguides.jp/testing.html#%E3%82%B3%E3%83%B3%E3%83%88%E3%83%AD%E3%83%BC%E3%83%A9%E3%81%AE%E6%A9%9F%E8%83%BD%E3%83%86%E3%82%B9%E3%83%88)
- [ActionController::HttpAuthentication::Basic](https://api.rubyonrails.org/v6.0.2.2/classes/ActionController/HttpAuthentication/Basic.html)
- [Authorization - HTTP ](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Authorization)
- [Base64 - MDN Web Docs 用語集 ウェブ関連用語の定義](https://developer.mozilla.org/ja/docs/Glossary/Base64)
- [module Base64 (Ruby 3.1 リファレンスマニュアル)](https://docs.ruby-lang.org/ja/latest/class/Base64.html)
- [ActionDispatch::Assertions::ResponseAssertions](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/ResponseAssertions.html)
- [rails/response.rb at 8015c2c2cf5c8718449677570f372ceb01318a32 · rails/rails · GitHub](https://github.com/rails/rails/blob/8015c2c2cf5c8718449677570f372ceb01318a32/actionpack/lib/action_dispatch/testing/assertions/response.rb#L30)
- [rack/utils.rb at main · rack/rack · GitHub](https://github.com/rack/rack/blob/main/lib/rack/utils.rb)
- [WWW-Authenticate-HTTP｜MDN](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/WWW-Authenticate)
- [HTTP 認証 - HTTP｜MDN](https://developer.mozilla.org/ja/docs/Web/HTTP/Authentication)
- [rails/http_authentication.rb at 8015c2c2cf5c8718449677570f372ceb01318a32 · rails/rails · GitHub](https://github.com/rails/rails/blob/8015c2c2cf5c8718449677570f372ceb01318a32/actionpack/lib/action_controller/metal/http_authentication.rb#L92)
- [rails/http_authentication.rb at 8015c2c2cf5c8718449677570f372ceb01318a32 · rails/rails · GitHub](https://github.com/rails/rails/blob/8015c2c2cf5c8718449677570f372ceb01318a32/actionpack/lib/action_controller/metal/http_authentication.rb#L105)
- [rails/http_authentication.rb at 8015c2c2cf5c8718449677570f372ceb01318a32 · rails/rails · GitHub](https://github.com/rails/rails/blob/8015c2c2cf5c8718449677570f372ceb01318a32/actionpack/lib/action_controller/metal/http_authentication.rb#L111)
- [rails/http_authentication.rb at 8015c2c2cf5c8718449677570f372ceb01318a32 · rails/rails · GitHub](https://github.com/rails/rails/blob/8015c2c2cf5c8718449677570f372ceb01318a32/actionpack/lib/action_controller/metal/http_authentication.rb#L115)
- [rails/request.rb at 8015c2c2cf5c8718449677570f372ceb01318a32 · rails/rails · GitHub](https://github.com/rails/rails/blob/8015c2c2cf5c8718449677570f372ceb01318a32/actionpack/lib/action_dispatch/http/request.rb#L404)
- [rails/response.rb at 8015c2c2cf5c8718449677570f372ceb01318a32 · rails/rails · GitHub](https://github.com/rails/rails/blob/8015c2c2cf5c8718449677570f372ceb01318a32/actionpack/lib/action_dispatch/http/response.rb#L179)
- [rails/request.rb at 8015c2c2cf5c8718449677570f372ceb01318a32 · rails/rails · GitHub](https://github.com/rails/rails/blob/8015c2c2cf5c8718449677570f372ceb01318a32/actionpack/lib/action_dispatch/http/request.rb#L210)
- [rails/headers.rb at 8015c2c2cf5c8718449677570f372ceb01318a32 · rails/rails · GitHub](https://github.com/rails/rails/blob/8015c2c2cf5c8718449677570f372ceb01318a32/actionpack/lib/action_dispatch/http/headers.rb#L24)
- [rack/utils.rb at main · rack/rack · GitHub](https://github.com/rack/rack/blob/main/lib/rack/utils.rb)
- [ Active Support コア拡張機能 - Railsガイド](https://railsguides.jp/active_support_core_extensions.html)
- [HTTP Semantics （日本語訳）](https://triple-underscore.github.io/http-semantics2-ja.html)
- [ Active Record の基礎 - Railsガイド](https://railsguides.jp/active_record_basics.html#crud-%E3%83%87%E3%83%BC%E3%82%BF%E3%81%AE%E8%AA%AD%E3%81%BF%E6%9B%B8%E3%81%8D)
- [手続きオブジェクトの挙動の詳細 (Ruby 3.1 リファレンスマニュアル)](https://docs.ruby-lang.org/ja/latest/doc/spec=2flambda_proc.html)
- [ActionDispatch::Request](https://api.rubyonrails.org/v7.0/classes/ActionDispatch/Request.html)
- [Rails 7: importmap-railsとjsbundling-railsでのStimulusの扱いの違い｜TechRacho by BPS株式会社](https://techracho.bpsinc.jp/hachi8833/2022_03_04/115430)
- [週刊Railsウォッチ（20210426前編）Hotwireの詳細な解説記事3本、Rails 7に入る予定の機能ほか｜TechRacho by BPS株式会社](https://techracho.bpsinc.jp/hachi8833/2021_04_26/107414)
- [GitHub - hotwired/hotwire-rails: Use Hotwire in your Ruby on Rails app](https://github.com/hotwired/hotwire-rails)
- [Rails 7.0 + Ruby 3.1でゼロからアプリを作ってみたときにハマったところあれこれ - Qiita](https://qiita.com/jnchito/items/5c41a7031404c313da1f)
- [GitHub - hotwired/stimulus-rails: Use Stimulus in your Ruby on Rails app](https://github.com/hotwired/stimulus-rails)
- [jsbundling-rails/README.md at main · rails/jsbundling-rails · GitHub](https://github.com/rails/jsbundling-rails/blob/main/README.md)
- [GitHub - hotwired/turbo-rails: Use Turbo in your Ruby on Rails app](https://github.com/hotwired/turbo-rails)
- [HTML Over The Wire｜Hotwire](https://hotwired.dev/#screencast)
- [Turbo Handbook](https://turbo.hotwired.dev/handbook/introduction)
- [GitHub - hotwired/stimulus-rails: Use Stimulus in your Ruby on Rails app](https://github.com/hotwired/stimulus-rails#usage-with-javascript-bundler)
- [jsbundling-rails README（翻訳）｜TechRacho by BPS株式会社](https://techracho.bpsinc.jp/hachi8833/2022_09_21/121895)
- [Stimulus Handbook](https://stimulus.hotwired.dev/handbook/introduction)
- [Turbo: The speed of a single-page web application without having to write any JavaScript.](https://turbo.hotwired.dev/)
- [Forbidden header name (禁止ヘッダー名) - MDN Web Docs 用語集: ウェブ関連用語の定義｜MDN](https://developer.mozilla.org/ja/docs/Glossary/Forbidden_header_name)
- [Headers - Web API｜MDN](https://developer.mozilla.org/ja/docs/Web/API/Headers)
- [フェッチ API - Web API｜MDN](https://developer.mozilla.org/ja/docs/Web/API/Fetch_API)

#### 2. テキスト入力
ログイン・ログアウト・ユーザ作成がある程度上手くできた。そのためログイン後の状態にすぐにアクセスできるように`./open_firefox_nkun`を作った。このスクリプトにはnkunの認証情報を書き込んでいる。コントローラ名とアクション名を入れてアクセスするだけで認証情報入力した状態でブラウザを開ける。しかし確認ボタンだけ押さないといけないが、それなりに短縮できるはずだ。

テキスト入力についてはある程度目星がついている。railsの機能のaction textを使う方法だ。これは本を読んでいて知ったので本を参考に実装して行こうと思う。

認証の処理の草案が完成したところで一度コミットしておく。

###### 2.1.ActionTextのインストール
Gemfileを編集
```ruby
gem "image_processing", "~> 1.2"
```
コマンドを実行してaction textをインストール
```bash
./bin/rails action_text:install
Could not find gem 'image_processing (~> 1.2)' in locally installed gems.
Run `bundle install` to install missing gems.
```
bundle installが先らしい。
```bash
bundle install
./bin/rails action_text:install
...
warning " > @rails/actiontext@7.0.4" has incorrect peer dependency "trix@^1.3.1".
...
./bin/rails db:migrate
```
また、`which convert`、`which magick`で確認したところimagemagickはインストールされていないようだ。(docker側にsudo権限がないので今は無視、あとで修正版のイメージを作る作業と並行してインストールする。この際に本番環境でのセットアップについて同時に考える。)  
→本番環境のセットアップは要検討。今回の範囲として適切ではない可能性がある。(本件の拡張として考えるべきかもしれない)  
いまは、画像のアップロードを考えていないので今は不要とする。

###### 2.2.Room Controller、Room Modelの生成
1.2 MVCパターンの検討の検討でコントローラはRoomコントローラを導入することを検討していたためそれに従い生成する。
```bash
./bin/rails g controller rooms
```
これでroomsコントローラができた。これで今実装すべきコントローラは全部だと思う。なぜなら、ユーザから見てシステムは認証機能（ログイン・ログアウト、アカウント作成、アカウント削除、ユーザ情報の参照）、主機能（ひとり言、チャット機能）である。そのためそれらを切り替えるコントローラとしては２つ、`auths controller`と`rooms controller`であると考えたからだ。

`auths controller`はおおよその機能は実装している。残りはユーザ情報の参照とユーザの削除だろうか。今は重要ではないので後回しとしておく（プロトタイプなので）。

`rooms controller`はひとり言・チャット機能の可視性を制御する。そして同一名のモデルであるroomモデルを作ることでroom情報を保存する。  
そのためroomモデルも作成する。
```bash
./bin/rails g model room room_name:string
```
データベースに保存するレコードは1.3 ER図に書いている通り、idとroom_nameにしている。

###### 2.3.認証について
　roomsコントローラ上でアクセスできる画面は、すべて認証が必要なログイン後の画面である。そのため以前に実装した処理は共通の処理として`ApplicationController`に統合する。この段階で一度動作確認。

エラーがでた。モデルを作ってからマイグレーションをしていないことが原因のようだ。以下を実行。
```bash
./bin/rails db:migrate
```
統合は上手く行った。これでroomsコントローラにログインフィルタを適応できる。roomsコントローラ全体に適応するためオプションはなしで記述する。
```ruby
before_action :basic_auth
```
またルーティングを設定する。
```ruby
# rooms controller
resources :rooms
```
```bash
./bin/rails routes -c rooms
   Prefix Verb   URI Pattern               Controller#Action
    rooms GET    /rooms(.:format)          rooms#index
          POST   /rooms(.:format)          rooms#create
 new_room GET    /rooms/new(.:format)      rooms#new
edit_room GET    /rooms/:id/edit(.:format) rooms#edit
     room GET    /rooms/:id(.:format)      rooms#show
          PATCH  /rooms/:id(.:format)      rooms#update
          PUT    /rooms/:id(.:format)      rooms#update
          DELETE /rooms/:id(.:format)      rooms#destroy
```
`auths controller`は１ユーザあたり１つのユーザ情報しか見えない。そのためルーティングは`resource`でいいが、`rooms controller`は一人のユーザに対して複数のルームが紐づく。そのため`resources`でルーティングを定義する。

再ログインからroomに入る経路が変。何故か前の無効ユーザの情報でログインしようとしている。（とりあえずプロトタイプなのでここは外しておく）

###### 2.4.中間テーブルについて
　ユーザがみることができるルームの一覧を`rooms#index`として実装して一覧を`/rooms`に表示しようとしたところ中間テーブルが必要になることに気づいた。ER図でも書いたとおり、`UserRoom`テーブルである。ユーザ情報から直接roomテーブルにアクセスできないようにする代わりにひとり言、プライベートチャット、グループチャットを統合的に管理するために導入している。初期段階で導入するのは難しいかもしれないが、後々の修正が少ないことが予想されるため今回ははじめから中間テーブルを導入する。  

　本来、ユーザとルームは多対多の関係である。しかし、railsでは多対多を直接実現することはできない。そこで中間テーブルを使用して実現する。
　railsでは多対多を実装する方法として２つあるそうだ。以下に示す。  
1. `has_and_belongs_to_many`  
1. `has_many assoc_id, through: middle_id`

しかし、1は制約が多いためできるだけ2を使うことが推奨されているそうだ。そのため本件でも2の方法を使用する。

以下のコマンドを実行する。
```bash
./bin/rails g model UserRoom user_id:references room_id:references
```
タイムスタンプは不要なのでコメントアウトしておく（マイグレーションファイルの話）。

カラムの名前にidが不要だと思ったので一度削除。
```bash
 ./bin/rails d model UserRoom
```
再生成。
```bash
./bin/rails g model UserRoom user:references room:references
```
user modelとroom modelを編集。
```ruby
#user.rb
  has_many :user_rooms
  has_many :rooms, through: :user_rooms
#room.rb
  has_many :user_rooms
  has_many :users, through: :user_rooms
```
マイグレーションを実行。

また、ルームモデルの登場によってユーザの登録処理にひとり言ルームの作成を加える必要がある。

このことから、単純なユーザの作成とはならない。そのためフィクスチャによる初期データの投入では難しい。故に別の手段を考える必要がある。いま考えているのはシードファイルである。これはrubyのスクリプトを記述できる（フィクスチャでもできるがerbのような書き方）。こちらでなんとかできないか考えてみる。（ひとまず後）。  
興味が出たので一応下調べだけ。
- [フォームデータの送信 - ウェブ開発を学ぶ｜MDN](https://developer.mozilla.org/ja/docs/Learn/Forms/Sending_and_retrieving_form_data)
- [class Net::HTTP (Ruby 3.1 リファレンスマニュアル)](https://docs.ruby-lang.org/ja/latest/class/Net=3a=3aHTTP.html#S_POST_FORM)

ひとまず、一度フィクスチャでデータを入れる。データベースを再度作り直す。
```bash
./bin/rails db:migrate:reset 
./bin/rails db:fixtures:load FIXTURES=rooms,users
```
しかし、この状態では中間テーブルが空の状態。コンソールから直接書き込む。
```bash
./bin/rails c
```
```ruby
user=User.find_by(user_name: 'nkun')
room=Room.find_by(room_name: 'nkun')
user.rooms<<room
```
これで中間テーブルにデータが入ったはず。データベースで確認。
```bash
./bin/rails db
sqlite> .mode line
sqlite> select * from users;
        id = 1
 user_name = nkun
  password = password
created_at = 2022-12-13 15:54:43.229828
updated_at = 2022-12-13 15:54:43.229828

        id = 2
 user_name = xsan
  password = xpass
created_at = 2022-12-13 15:54:43.229828
updated_at = 2022-12-13 15:54:43.229828

        id = 3
 user_name = ysan
  password = ypass
created_at = 2022-12-13 15:54:43.229828
updated_at = 2022-12-13 15:54:43.229828
sqlite> select * from rooms;
        id = 108902914
 room_name = nkun
created_at = 2022-12-13 15:54:43.226625
updated_at = 2022-12-13 15:54:43.226625
sqlite> select * from user_rooms;
     id = 1
user_id = 1
room_id = 108902914
```
room_idを１にしているはずが変な値になっていること以外は問題ない。（なぜ？→フィクスチャファイルの保存しわすれかも）とりあえずこれで一旦OK。  
→今のやり方だとやっぱり少し手間がかかる。

次は一覧を取得してindexに表示する。
```ruby
    #一覧を表示する。
    def index
        @user = session[:user]
        @rooms = @user.rooms
    end
```
これで変数は設定できたはず。ビューにつなげる。
```ruby
<% @rooms.each do |room| %>
    <p>
        <%= link_to room.room_name, url_for(room) %>
    </p>
<% end %>
```
とりあえず段落の書き方だが上記でリンクの貼り付けができた。  
後は、このインスタンスの表示用のビューを用意する。(`show.html.erb`の作成)
```ruby
<h1>
    <%= @room.room_name %>
</h1>
```
ひとまず名前だけ出すビューを表示。またscaffoldを見直すと便利そうなメソッドがあることに気づいた。
```ruby
  before_action :set_val, only: %i[ show ]
  ...
  private
  def set_val
      @room = Room.find(params[:id])
  end
```
これはポケットリファレンスによれば、ルートパラメータを取得するに相当。クリックしたURLの末尾のIDを取得してくれる。  
その他にもクエリやポストデータも拾ってくれるとても嬉しいもの。  
早速真似して実装した。

表示は上手く行った。これでaction textを入れ込む土台ができた。

###### 2.5.action textの利用
まずactive storageについて調べた。
- [ Active Storage の概要 - Railsガイド](https://railsguides.jp/active_storage_overview.html#%E8%A6%81%E4%BB%B6)

imagemagickじゃないとだめだと思ったらそうでもないらしい。必要なサードパーティ製ソフトは以下。
- [GitHub - libvips/libvips: A fast image processing library with low memory needs.](https://github.com/libvips/libvips)
- [FFmpeg](http://ffmpeg.org/)
- [Poppler](https://poppler.freedesktop.org/)

いまdockerfileにそれがないので追加をする。
- [Build for Ubuntu · libvips/libvips Wiki · GitHub](https://github.com/libvips/libvips/wiki/Build-for-Ubuntu)

上記によればlibvipsは以下のコマンドで入るらしい。（LGPL系のライセンス)
```bash
sudo apt install libvips
```

- [How To Install ffmpeg on Ubuntu 22.04｜Installati.one](https://installati.one/install-ffmpeg-ubuntu-22-04/)

上記によればffmpegは以下のコマンドでインストールできるそうだ。
```bash
sudo apt-get -y install ffmpeg
```

- [GitHub - freedesktop/poppler: The poppler pdf rendering library](https://github.com/freedesktop/poppler)

上記によればGPL系のOSSライセンスだそうだ。また、

- [Poppler - TeX Wiki](https://texwiki.texjp.org/?Poppler)
- [Ubuntu – パッケージ検索結果 -- poppler](https://packages.ubuntu.com/ja/poppler)

上記によればpopplerをインストールするには以下のコマンドらしい。
```bash
sudo apt install poppler-utils poppler-data
```
---

nginxのライセンスの調査以下に示す。作業しやすいように整形する。
``` 
Copyright (C) 2002-2021 Igor Sysoev
Copyright (C) 2011-2022 Nginx, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met: 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```
機械翻訳にかけると以下の通り。
```
著作権 (C) 2002-2021 Igor Sysoev
著作権(C) 2011-2022 Nginx, Inc.
すべての著作権を保有します。

ソースコード形式およびバイナリ形式での再配布および使用は、変更の有無にかかわらず、以下の条件を満たす場合に限り許可されます。1. 1. ソースコードの再配布は、上記の著作権表示、この条件一覧、および以下の免責事項を保持する必要があります。2. 2. バイナリ形式で再頒布する場合は、頒布物とともに提供される文書および/またはその他の資料において、上記の著作権表示、本条件一覧、および以下の免責事項を複製する必要があります。

このソフトウェアは、作者および貢献者によって「現状のまま」提供され、商品性および特定目的への適合性の黙示保証を含むがこれに限定されない、いかなる明示または黙示の保証も放棄される。 また、いかなる場合においても、著者または貢献者は、直接的、間接的、偶発的、特別、典型的、または結果的損害（代替品またはサービスの調達、使用、データ、または利益の損失、または事業の中断を含むが、これに限定されない）に対して責任を負わないものとします。
本ソフトウェアの使用により生じたいかなる損害についても、その原因が契約、厳格責任、不法行為（過失その他を含む）のいずれであっても、またそのような損害の可能性について知らされていたとしても、いかなる責任論によっても、責任を負いません。
```

一応記述した。調べたところBSDライクなライセンス（MITもBSD系らしい）。上記を読んでいる限り使う分に関しては問題なさそう。  
しかし、passengerとnginxの導入の話は本番環境の話になるので今（開発環境）は範囲外になると思ったのでやめておく。別の機会にする。

---

active storageを有効にするプログラムをインストールするコマンドをDockerfileに記述してイメージをビルドする。

以下コマンドメモ。
```bash
docker build -t rails_container:remake_gu .
docker run --name dev_prototype2 -it -v $(pwd):/home/general_user/rails_dir -p 35729:35729  rails_container:remake_gu
```
そして、Gemfileの中身をインストールすれば使えるようになるはず。
```bash
bundle install
```
データベースに関しては再作成は不要だと思われる。なぜならSQLiteだから。SQLiteはファイルとして管理されるはずなので今回は操作不要(のはず)。他のデータベース(MySQL,PostgreSQLなど？)だと必要かもしれない。

動作確認のためにサーバを起動する。
```bash
./bin/dev
```
アクセスはスクリプトでホストから接続する。  
→OK以前と同じ動作を確認。

これで、環境が新しく変わっても、マウント（今回はバインドマウント）して`bundle install`すれば続きから再開できることがわかった。

active storageに必要なソフトウェア３つをインストールできたのでコードの続きを書いていく。

action textを使うためには保存するためのモデル（データベース）が必要だそうなのでモデルを生成する。チャットの内容を保存するモデルはChatモデルなのでその作成をする。カラムなどはER図を参考にして作成し、以下のコマンドを実行する。
```bash
./bin/rails g model chat content:text user:references room:references
```
また、user、roomモデル、chatモデルにリレーションを定義
```ruby
#user.rb, room.rb
  #Chatモデルとのリレーションを定義する
  has_many :chats
#chat.rb こちらはコマンドでreferencesを指定したので自動で追加されていた。
  belongs_to :user
  belongs_to :room
```

これでモデルのリレーションはOK。

本を読み直しているとaction textはデータベースのカラムがモデル側に不要。厳密には外部キー扱いになる。そのため、上記のコマンドは良くないと思う。contentの部分も外部キーにするか、本に合わせてなしにするかのどちらかになると思う。

データベースで管理する点を考えると外部キーにして管理、つまりchatテーブルを中間テーブル扱いにして置くほうがいいと感じた。以下のコマンドを実行する。
```bash
./bin/rails d model chat
./bin/rails g model chat content:references user:references room:references
```
本の内容を考えると上記のchatモデルに加えてストレージとのやり取りをし、chatモデルと１対１のリレーションを持つモデルを作ったほうが作りやすいかもしれない。この点に関しては適切出ないかもしれないがとにかく動くものを作るという点を優先しようと思うので実行する。以下のコマンドを実行する。

```bash
./bin/rails g model ChatText
```
これで、主キーのidを持つモデルができる。このモデルを通じてaction textを操作すればいいと考えれば良いのでこの方が問題が単純化されるかもしれない。

一度整理する。アクションテキストはリッチテキスト情報を扱う仕組みであって、別にデータベースを構築している。それを便利に扱うためにカラムがほとんど空のモデルChatTextモデルを作成した。見え方としてはChatTextを使用することでアクションテキストを扱うことができるように見える。  
そして、テキストの内容と発信者、発信場所を紐付けるためにChatモデルがある。

という状態である。

また、モデルを作ったのでマイグレーションを実行しておく。
```bash
./bin/rails db:migrate
```
また、ChatモデルとChatTextモデルのリレーションを整理しておく。
```ruby
#chat.rb
class Chat < ApplicationRecord
  #ユーザとルームのidと紐付け
  belongs_to :user
  belongs_to :room
  #コンテンツを紐付け、１対１の関係
  #chatからchattextを呼び出すため、chatを主とする。
  belongs_to :chat_text
end
#chat_text.rb
class ChatText < ApplicationRecord
    #チャットの内容と紐付ける
    has_rich_text :content
    #Chatモデルと紐付け。呼び出されるのがこちらなのでこちらを従とする。
    has_one :chat
end
```

action textの使い方のリンクを貼っておく。
- [ Action Text の概要 - Railsガイド](https://railsguides.jp/action_text_overview.html)

次は、フォームを作る。
まずはテキストの内容を写経する。

設定などは無茶苦茶だがとりあえず入力フォームをビューに表示できた。以下コード。
```ruby
#_form.html.erb
<%= form_with model: chat_text, url: path_to_post do |f| %>
    <div class="field">
        <%= f.label :content %>
        <%= f.rich_text_area :content %>
    </div>
    <div class="actions">
        <%= f.submit %>
    </div>
<% end %>
```
```ruby
#show.html.erb
<%= render 'form', chat_text: @chat_text, path_to_post: url_for(@room) %>
```
```ruby
#rooms_controller.rb
def show
    @chat_text = ChatText.new
end
...
private
def content_params
    params.require(:chat_text).permit(:content)
end
```
ルーティングが決定していないのも問題である。しかしこれはaction cableの問題が絡むのでここで一旦終了とする。

当初の目的であったテキストの入力が可能になった。そのため2.テキスト入力は完了とし次に進む。

#### 3. 履歴表示
　ログインをし、テキスト入力ができるようになった。後はテキストをサーバに送信し送信内容を受け取って表示する処理が必要になる。これらの処理についてはaction cableで実現できることが調べてわかった。そのためaction cableを使用し製作を進めていく。

action textの導入ができた段階を一度コミットしておく。

テキスト入力ができるが現状ではポストができない。
action cableの導入には、まずテキストのポストが必要なのでテキストのポストと表示ができるようにする。

ポストできるようにルーティングを設定する。
```ruby
  resources :rooms do
    #発言内容を保存するための設定
    post 'record_chat'
  end
```
上記のように設定するとルーティングは以下。
```bash
./bin/rails routes -c rooms
          Prefix Verb   URI Pattern                           Controller#Action
room_record_chat POST   /rooms/:room_id/record_chat(.:format) rooms#record_chat
```
`/rooms/:room_id/record_chat(.:format)`にポストすると`rooms#record_chat`が起動する。
URLは`url_for(@room)`とすると`/rooms/:room_id`となる。そのため末尾に追加が必要。

上記の場合、ルーティングの書き方は以下のほうがいいか？
```ruby
  resources :rooms do
    member do
      #発言内容を保存するための設定
      post 'record_chat'
    end
  end
```
ルーティングは以下になった。
```bash
 ./bin/rails routes -c rooms
          Prefix Verb   URI Pattern                      Controller#Action
record_chat_room POST   /rooms/:id/record_chat(.:format) rooms#record_chat
```
これでURLヘルパーが使えると思う。
```ruby
<%= render 'form', chat_text: @chat_text, path_to_post: record_chat_room_path %>
#pathは"/rooms/108902914/record_chat"となっている
```
保存のメソッドは簡単にしてみる
```ruby
#発言内容を保存する処理を書く
def record_chat
    #発言内容を元に変数を作成
    @chat_text = ChatText.new(content_params)
    #保存を検証
    @chat_text.save
    redirect_to action: :show
end
```
カラムを一部変更。
```
class CreateChats < ActiveRecord::Migration[7.0]
  def change
    create_table :chats do |t|
      t.references :chat_text, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :room, null: false, foreign_key: true

      t.timestamps
    end
  end
end
```
データベース再作成。
```bash
./bin/rails db:drop
./bin/rails db:create
./bin/rails db:migrate
./bin/rails db:fixtures:load FIXTURES=
./bin/rails db:fixtures:load FIXTURES=users,rooms
#手動で中間テーブルを紐付け
./bin/rails c
user=User.find(1)
room=Room.find(1)
user.rooms<<room
```
元の画面が開いたのを確認。

また、リレーションを修正。Chatは３つのテーブルが接続されていることを意識して書き直し。
```ruby
#user.rb
    #Chatモデルとのリレーションを定義する
    has_many :chats
    has_many :chat_texts, through: :chats
#room.rb
    #Chatモデルとのリレーションを定義する
    has_many :chats
    has_many :chat_texts, through: :chats
#chat_text.rb
    #Chatモデルと紐付け。呼び出されるのがこちらなのでこちらを従とする。
    has_one :chat
    #チャットテキスト自体もユーザ名とルーム名と紐付ける必要があるので定義
    has_one :user, through: :chat
    has_one :room, through: :chat
#chat.rb
    #chatからchattextを呼び出すため、chatを主とする。
    belongs_to :chat_text
```
これでchat_text_idがないというエラーはなくなった。おそらくchat_textというカラムがないことが問題だったのでそこを修正したのが良かったのではないかと思われる。現在のコントローラの設定では中間テーブルを参照しているためメッセージはオブジェクトの形式で表示される。
```ruby
#rooms_controller.rb#show
@chats = Chat.where(user: @user, room: @room)
```
```ruby
<div>
    <% @chats.each do |chat| %>
        <p><%= chat.chat_text %></p>
    <% end %>
</div>
```
```html
#<ChatText:0x00007f7cd248c8c0>

#<ChatText:0x00007f7cd2460b08>
```
この状態だとaction textを導入しいたメリットがないのでビューを改善する。  
→意外と簡単だった。
```ruby
<div>
    <% @chats.each do |chat| %>
        <p><%= chat.chat_text.content %></p>
    <% end %>
</div>
```
これで以下のHTMLを得られた。
```html
これはテストです。

表示がオブジェクトになっています。
```

- [週刊Railsウォッチ（20201208前編）レガシーRailsアプリを引き継ぐときの6つの作業、サーバーレスプロジェクトをRailsに移行ほか｜TechRacho by BPS株式会社](https://techracho.bpsinc.jp/hachi8833/2020_12_08/101364)
- [Add support for eager loading all rich text associations at once by swanson · Pull Request #39397 · rails/rails · GitHub](https://github.com/rails/rails/pull/39397)
  
設定を見直す。`with_rich_text_#{name}`を使う。  
→しかし、上手く行かない。現状問題がないので頭の片隅にだけおいておく。

これで入力結果を表示できるようになった。→action cableの基盤ができたはず。

まずは、本の写経をする。  
以下のコマンドを実行する。
```bash
./bin/rails g channel room speak
```

変更を加える前に一度コミットしておく。

- [ Action Cable の概要 - Railsガイド](https://railsguides.jp/action_cable_overview.html)
- [Rails 5: Action Cable demo - YouTube](https://www.youtube.com/watch?v=n0WUjGkDFS0)

Action Cableの使い方は上記と手元の本を参考にする。  
(上記のDHH氏の動画の内容を本できれいにまとめてくれているので主にそちらを参考にしようと思う。)

写経しようとしたが、今の状況にあっていないので状況に合わせて書き直す。

本によれば編集すべきファイルは以下の通り。

1. channels/room_channel.rb(サーバサイド)
1. javascript/channels/room_channel.js(クライアントサイト)
1. views/rooms/show.html.erb(クライアント側のビューファイル)

写経中の疑問点を整理。
- [element.insertAdjacentHTML - Web API｜MDN](https://developer.mozilla.org/ja/docs/Web/API/Element/insertAdjacentHTML)
- [ActionController::Renderer](https://api.rubyonrails.org/classes/ActionController/Renderer.html#method-i-render)

読んでいると現在の構成からの変更が必要だと思う。

現状は、通常のフォームの挙動を利用している。現在の処理の流れは以下の通り。

1. フォームに送信情報を入力する。
1. 送信ボタンで送信内容をPOSTする。
1. 紐付いたURLにPOSTし、対応するアクションを実行する
1. アクション内で送信内容を保存、画面を再描画する。

しかし、action cableを使うとするとPOSTするという動作がどうやらできなそうだ（不可能ではなさそうだが難易度が高そう）。  
本で書かれている内容を要約すると以下の通りである。

1. フォームに送信情報を入力する。
1. 'Enter'を押す。
1. 送信アクション（クライアント）で送信内容を送信する。
1. 対応するアクション（サーバ）で送信内容を保存し、描画方法と内容を指定しクライアントに送信する。
1. 受信内容に応じてdocumentに要素を挿入する。

そのためまず、保存するという動作を記述する場所が変わる。  
また、送信内容の描画方法を指定するための部分テンプレートの用意も必要。  
といった変更も必要だとおもわれる。  
また'Enter'を押すは、送信ボタンを押すor'shift+Enter'を押すにしたいと思う（できれば）。

以下の手順で修正していこうと思う。

1. スタイルシートの整理
1. クライアント側のコードを追加する。
1. サーバサイドのコードを実装する。

##### 3.1 スタイルシートの整理
　本を読んでいると必要だと思ったが、今回はaction textを使用しているので特に必要はなかった。しかし内容を反映するためのコードは必要。以下。  

---

追記：サーバサイド側のコードであったほうが便利だと気づいた。追加する。
```ruby
<div class='chat_box'>
    <div class='user_box'>
        <%= chat.user.user_name %>
        <%= chat.created_at %>
    </div>
    <p><%= chat.chat_text.content %></p>
</div>
```

---

```ruby
<div>
    <% @chats.each do |chat| %>
        <p><%= chat.chat_text.content %></p>
    <% end %>
</div>
```
ただ、上記だと内容の境目がないので、ボーダーを追加する。
- [border - CSS: カスケーディングスタイルシート｜MDN](https://developer.mozilla.org/ja/docs/Web/CSS/border)

```ruby
#chat.scss
.chat_box {
    border: 1px solid;
}
#application.sass.scss
@import 'chat.scss';
```

少し雑だが、上記で境界がついた。また、こうみるとチャットの内容だけ表示しているのは味気ないのと後々のコードを考えるとユーザ名があったほうがいいと感じたため以下のように修正。
```ruby
#show.html.erb
<div>
    <% @chats.each do |chat| %>
        <div class='chat_box'>
            <div class='user_box'>
                <%= chat.user.user_name %>
            </div>
            <p><%= chat.chat_text.content %></p>
        </div>
    <% end %>
</div>
#chat.scss
.chat_box {
    border: 1px solid;
}
.user_box {
    background-color: gray;
}
```
中間テーブルを使っているメリットがここで出た。発言ないように紐付いていたユーザ名を簡単に取り出すことができた。
色については後々で修正する。

また、htmlについての疑問点を整理。
- [データ属性の使用 - ウェブ開発を学ぶ｜MDN](https://developer.mozilla.org/ja/docs/Learn/HTML/Howto/Use_data_attributes)

##### 3.2 クライアントサイドを実装
###### 3.2.1 ビューの実装
　イベントを追加するためにフォームの入力部分と送信部分のボタンのクラスを指定する。

action textを使用しているためフォームのクラス名は`trix-content`である。  
送信ボタンの方には指定はないので自分でつける。以下に示す。

```ruby
<%= f.submit "送信", class: 'submit_buttom'%>
```

上記２つの要素をjsで取得して、それらにイベントを追加する。

と思ったが、サーバを起動しているターミナルをみるとエラーが出ている。一部以下に示す。
```bash
Could not execute command from ({"command"=>"subscribe", "identifier"=>"{\"channel\":\"RoomChannel\"}"}) [SyntaxError - /home/general_user/rails_dir/app/channels/room_channel.rb:24: syntax error, unexpected end-of-input, expecting `end']: /home/general_user/.rbenv/versions/3.1.2/lib/ruby/gems/3.1.0/gems/bootsnap-1.15.0/lib/bootsnap/load_path_cache/core_ext/kernel_require.rb:32:in `require' | /home/general_user/.rbenv/versions/3.1.2/lib/ruby/gems/3.1.0/gems/bootsnap-1.15.0/lib/bootsnap/load_path_cache/core_ext/kernel_require.rb:32:in `require' | /home/general_user/.rbenv/versions/3.1.2/lib/ruby/gems/3.1.0/gems/zeitwerk-2.6.6/lib/zeitwerk/kernel.rb:30:in `require' | /home/general_user/.rbenv/versions/3.1.2/lib/ruby/gems/3.1.0/gems/activesupport-7.0.4/lib/active_support/inflector/methods.rb:280:in `const_get' | /home/general_user/.rbenv/versions/3.1.2/lib/ruby/gems/3.1.0/gems/activesupport-7.0.4/lib/active_support/inflector/methods.rb:280:in `constantize'
```

一度ログアウトしてみて変化があるかどうかみる。

変化はないみたい。しかし、本を読んでいるとログインしている状態だとaction cableの状態についても変わるそうなのでその点はしっかりと注意したい。

しかし、action cableとURLをどのように紐付けているかわかっていないので一度そのあたりを把握したい。

なお、ブラウザを落とすと以下のメッセージが出る。
```bash
Finished "/cable" [WebSocket] for 172.17.0.1 at 2022-12-19 04:12:02 +0000
```

application.jsを読むとaction cableを読み込んでいる。そのためこの行をコメントアウトしaction cableを使用したいビューに読み込ませると上手く行くかもしれない。
```js
import "./channels"
```
上記の行をコメントアウトしてターミナルを確認する。  
→予想通りaction cableが無効になった。

ライブリロードの設定が足りなかった。以下を追加。
```ruby
  watch(%r{app/javascript/.+\.js})
  watch(%r{app/javascript/channels/.+\.js})
```
javascriptのインクルードタグを`show.html.erb`につける。
```ruby
<%= javascript_include_tag "room_cable", "data-turbo-track": "reload", defer: true %>
```
room_cable.jsの内容は先程コメントアウトした内容を記述した。この状態でブラウザに接続すると、`mypage`だとaction cableが起動しなかったが、ルームに入るとaction cableが起動するようになった。ルーム一覧に対してaction cableを使用したいためその調整をする。
```ruby
#application.html.erb
    <%# 個別に必要なスクリプトを読み込む %>
    <%= yield :additional_scripts %>
```
これでもできるが、この方法だと毎回ビューの冒頭にjavascriptのスクリプトのインクルードタグを書かなければならない。おそのため別にレイアウトを作る。
```ruby
#application.html.erb
  <%= content_for?(:additional_scripts) ? yield(:additional_scripts):nil %>
```
```ruby
#room_layout.html.erb
<%# room で使用する共通のjavascriptを配置する。%>
<% content_for :additional_scripts do %>
    <%= javascript_include_tag "room_cable", "data-turbo-track": "reload", defer: true %>
<% end %>

<% content_for :room_content do %>
    <%= yield %>
<% end %>
<%= render template: 'layouts/application' %>
```
（２つ目のcontent_forが必要か不明だが今の所上手く行っていること、後々使うかもしれないのでこのままにする。)  
この記述をしてコントローラの記述を変える。
```ruby
#room_controller.rb
 #レイアウトを指定。
 render layout: 'room_layout'
```
使用するアクションにこれらを当てはめる。しかしすべてのアクションに書くのは骨が折れるので工夫したい。room_controller.rbに以下を追記。
```ruby
    #レイアウトをセット
    layout 'room_layout', only: %i[ index show ]
```
これで今の所上手く行っているように見える。  
ターミナルを確認したがaction cableが起動している。ひとまずレイアウトはOKとする。

これでaction cableを使用する範囲を絞ることができた。ここからはaction cable本体の記述をしていく。

　上記までの作業で一度コミットし、元に戻れるようにする。(コメント：レイアウトの追加と調整)

　いきなり、以前の作業を修正することになるが、  
　まず、既存のボタンはPOSTメソッドと紐付いているため外しておく。処理の内容もsubmitではないのでクラス名も変える。

そのためフォーム周りは以下のように記述する。
```ruby
<div>
    <%= render 'form', chat_text: @chat_text, path_to_post: record_chat_room_path %>
    <button type="button" class="send_content">送信</button>
</div>
```
まず、わかりやすいボタンの方からイベントを追加する。

しかし、何故か購読が始まらない。なぜ？

###### 3.2.2 action cableの購読
　なぜ購読が始まらない？とりあえず認証が邪魔をしているかもしれないので一度外してみる。  
→認証を外すとユーザ情報が消えてエラーが出たので認証が不要なところでaction cableを有効にしてみる。

```ruby
#views/auths/show.html.erb
(略)
<%= javascript_include_tag "room_cable", "data-turbo-track": "reload", defer: true %>
```
しかし、変わらず購読が始まらない。github issueでないか確認する。  
→調べてもない。

コンソールを注視すると以下のメッセージが出ていることがわかった。

```bash
04:07:06 web.1        | Started GET "/cable" for 172.17.0.1 at 2022-12-20 04:07:06 +0000
04:07:06 web.1        | Cannot render console from 172.17.0.1! Allowed networks: 127.0.0.0/127.255.255.255, ::1
04:07:06 web.1        | Started GET "/cable" [WebSocket] for 172.17.0.1 at 2022-12-20 04:07:06 +0000
04:07:06 web.1        | Successfully upgraded to WebSocket (REQUEST_METHOD: GET, HTTP_CONNECTION: keep-alive, Upgrade, HTTP_UPGRADE: websocket)
04:07:06 web.1        | Could not execute command from ({"command"=>"subscribe", "identifier"=>"{\"channel\":\"RoomChannel\"}"}) ...(略)
```
これをみるとIPアドレスが違うようだ。いまは`172.17.0.2`しか許可していない。そのためエラーが出ている可能性がある。つまりdockerでaction cableを使用するときは単純なネットワークの設定では不十分である可能性がある。

ネットワークの設定について変えてみる。

###### 3.2.2.1 railsプロジェクトから設定  

　以下を参考。
  - [ Rails アプリケーションを設定する - Railsガイド](https://railsguides.jp/configuring.html#rails%E7%92%B0%E5%A2%83%E3%81%AE%E8%A8%AD%E5%AE%9A)
  - [Rails: サーバーのIPアドレスを環境変数で設定するにはHOSTではなくBINDINGを使う｜TechRacho by BPS株式会社](https://techracho.bpsinc.jp/hachi8833/2022_01_19/114936)

　上記によれば、`BINDING`という環境変数を設定すればいいらしい。dockerで以下のコマンドを実行
```bash
export BINDING="172.17.0.2"
```
これを実行した後は、Procfile.devのIPアドレスのバインドも外す。実行して確認。  
→サーバを起動した結果IPアドレスが固定されていた。これはDockerfileで修正するべき点なので修正を加える。
```dockerfile
ENV BINDING="172.17.0.2"
```
composeファイルで指定したほうが都合がいい。

この状態でaction cableが使えるか確認する。  
→上手く行かない。なぜ"172.17.0.1"が使われているのだろうか？エラー、"Cannot render console from 172.17.0.1! Allowed networks: 127.0.0.0/127.255.255.255, ::1"はどういうことだろうか？

少しづつ整理する。調べていくとおおよそ以下の内容だと思われれる。

  1. 127.0.0.0/127.255.255.255 →　ループバックアドレス
  1. ::1 →自分自身を表すIPアドレス、127.0.0.0.1と同義（IPv4の場合）。  
  おそらく本質的には両方同じ？(ホストを表すという意味において同じ。１つ目は代表として127.0.0.1が使われる。)

127.0.0.0/127.255.255.255はIPアドレスとして正確な書き方をすると、`127.0.0.0/8`になると思う。このように書くと、`127.0.0.0`〜`127.255.255.255`のローカルホストで使うとして当てはめられているIPアドレス全体を表すらしい。クラスでいうとAだそう。（情報処理試験で出たやつ）。

以下参考。
- [127.255.255.255 予約済みIPアドレス｜IPアドレス (日本語) 🔍](https://ja.ipshu.com/ipv4/127.255.255.255)
- [ループバックアドレス【loopback address】127.0.0.1 / ::1](https://e-words.jp/w/%E3%83%AB%E3%83%BC%E3%83%97%E3%83%90%E3%83%83%E3%82%AF%E3%82%A2%E3%83%89%E3%83%AC%E3%82%B9.html)
- [IPアドレス計算 127.0.0.0/8](https://www.ipkeisan.com/?ip=127.0.0.0&len=8)

そのため少なくとも開発環境ではIPアドレスをバインドするだけでは不十分かもしれない。そうなると開発用のコンテナではIPアドレスの設定が必要かもしれない。

エラーの内容を予測すると、ローカルホスト(::1 or 127.0.0.1)と127.0.0.0〜127.255.255.255が許可されている。しかし、`172.17.0.1`は許可されていないという状態だと思う。

ループバックアドレスはホストで使われているので`172.0.0.0`〜`172.255.255.255`を許可するのがいいだろうか。そのためにはrails側では設定できない？と思う（というよりする意味があまりない、なぜなら開発中でしか使わないので）。そのためdocker側で設定をする必要があると思う。


###### 3.2.2.2 dockerで設定
　dockerの設定でIPアドレス、というよりはネットワークの設定を細かくするのはできなくはないが正直面倒かもしれない。修正のたびにイメージをビルドしないといけないし無意味な時間が多く流れることが予想される（実際今のDockerfileを作るときも結構時間がかかった）。現時点では、最低限動くイメージを作ることには成功している。つまりイメージは存在する。そのためDocker Composeを使って追加の設定をしていったほうがいいと思った。

　Docker ComposeはDockerをインストールした段階で使用可能になっている。ゆえにcomposeファイルの構築をしていく。

- [Compose 仕様｜Docker ドキュメント](https://matsuand.github.io/docs.docker.jp.onthefly/compose/compose-file/)
- [compose-spec/spec.md at master · compose-spec/compose-spec · GitHub](https://github.com/compose-spec/compose-spec/blob/master/spec.md)
- [Compose ファイル バージョン 3 リファレンス｜Docker ドキュメント](https://matsuand.github.io/docs.docker.jp.onthefly/compose/compose-file/compose-file-v3/)

最新バージョンは3.8のはずだが、リファレンスの途中に何故か3.9の文字がある。何だこれ？  
→一度3.9で作ってみて変だったら3.8にする.

docker-compose.ymlの記述をしていく。  
イメージはdocker runの内容を記述していくイメージ。

- [Compose 仕様｜Docker ドキュメント](https://matsuand.github.io/docs.docker.jp.onthefly/compose/compose-file/#restart)
- [バインドマウントの利用｜Docker ドキュメント](https://matsuand.github.io/docs.docker.jp.onthefly/storage/bind-mounts/#use-a-bind-mount-with-compose)

上記と手元の本を参考に以下の記述をした。
```docker
version: "3.9"
services:
  rails:
    container_name: rails
    image: rails_container:remake_gu
    volumes:
      - type: bind
        source: ./
        target: /home/general_user/rails_dir
    restart: always
    ports:
      - "35729:35729"
      - "3000:3000"
    environment:
      BINDING: 172.17.0.2
    tty: true #この行がないとコンテナに入れない。
```
一度起動してサーバが起動できるか確認する。  
以下のエラーが出た。
```
Cannot assign requested address - bind(2) for ...
```

---
追記:  
上記のエラーはどうやら許可されていないIPアドレスを指定した場合に表示される可能性がある。docker composeではなく、単純なdocker runでコンテナを作成し、`172.17.0.1`をバインドしてサーバを起動したが、同一（おそらく）のエラーがでた。

疑問点はおおよそ以下の点。
1. 許可されたIPアドレスとは？
1. 許可する方法は？
1. 読み替えて(DNSで)、使用することはできないだろうか？それはどう実現するのだろうか？

また、
linuxに関する知識も未だ不十分である。その点も考慮して調べた方がいいと思う。（実はこんなコマンドがあったとかあるかもしれない）

---

以下を参考。
- [Rails server breaks after Webpacker installed · Issue #762 · rails/webpacker · GitHub](https://github.com/rails/webpacker/issues/762)

```
host: 172.17.0.2
```
上記を追加すると上手く行くかもしれない。  
→上手く行かない。というより設定として存在しない。

まず、バインドをなくしてサーバを起動する。  
→サーバは起動できた。

`docker compose up -d`で以下のエラーがでた。
```
failed to create network rails_network: Error response from daemon: Pool overlaps with other one on this address space
```
以下参考。
- [使用していない Docker オブジェクトの削除（prune） — Docker-docs-ja 20.10 ドキュメント](https://docs.docker.jp/config/pruning.html)

`docker system prune`を実行する。

サブネットを使用するといいかもしれない。以下参考。
- [Docker Compose入門 (4) ～ネットワークの活用とボリューム～｜さくらのナレッジ](https://knowledge.sakura.ad.jp/26522/)

上手く行かない。

許可されたIPアドレスの設定をすればいいかもしれない。しかしどうすればいい？ファイアウォールの設定だろうか？

もしくは、DNSを利用する方法はどうだろうか。IPアドレスを読み替えて対応する。

上記をまとめる。

1. ~~ファイアウォールの設定~~(よく考えると関係ない)
1. DNSの利用でIPアドレスを読み替える。
1. ポートの設定をもっとしっかり調べる。（もしかするとIPアドレスごと変えられるかもしれない）

今後の問題点を考えるとネットワークアドレスを書き換える設定があれば便利だができるかわからない。とりあえず書く量が多くなりそうだが、単純にできそうなのはポートの設定だと思うのでまずはそちらを試す。

さくらのナレッジの下部のリンクにいろんな形のcomposeの構成があった。例えば以下の例など。
- [awesome-compose/nginx-flask-mysql at master · docker/awesome-compose · GitHub](https://github.com/docker/awesome-compose/tree/master/nginx-flask-mysql)

以下のブログにある書き方、やはりIPアドレスを書き込む方法はあるらしい。公式のリファレンスを探す。
- [まだdocker-composeのホスト側portを考えるのに疲弊しているの？ 〜IP指定してwell-known ports使い放題、同時に1677万案件回す〜 - 勉強日記](https://wand-ta.hatenablog.com/entry/2020/05/23/011001)

以下に示す。
- [ports｜Compose 仕様｜Docker ドキュメント](https://matsuand.github.io/docs.docker.jp.onthefly/compose/compose-file/#ports)

Long Syntaxというところで細かい設定について言及されている。

```
    ports:
      - target: 3000
        host_ip: 172.17.0.2
        published: 3000
        protocols: tcp
        mode: host
      - target: 35729
        host_ip: 172.17.0.2
        published: 35729
        protocols: tcp
        mode: host
```
しかしエラーが出る。

action cable側を調べた。以下に示す。
- [7.2 許可されたリクエスト送信元｜Action Cable の概要 - Railsガイド](https://railsguides.jp/action_cable_overview.html#%E8%A8%B1%E5%8F%AF%E3%81%95%E3%82%8C%E3%81%9F%E3%83%AA%E3%82%AF%E3%82%A8%E3%82%B9%E3%83%88%E9%80%81%E4%BF%A1%E5%85%83)

調べると、文字通り許可されたリクエスト送信元というものがあった。こっちを先に調べられていたら良かったかもしれない。

以前のコンテナを消してしまったので、修正分を含めてイメージを作り直す。以下のコマンドを実行。
```bash
docker build -t rails_container:rails_on_jammy .
```
コンテナの作成は今回で追加したdocker-compose.ymlを使う。一度作った後は単純なdocker runよりも楽にコンテナを作ることができるとわかったので、これを使う。

コンテナの作成は以下。
```bash
docker compose up -d
```

コンテナを立ち上げてbundle installを実行し、サーバを起動したが以下のエラーが出た。
```
/home/general_user/.rbenv/versions/3.1.2/lib/ruby/gems/3.1.0/gems/puma-5.6.5/lib/puma/binder.rb:341:in `initialize': Cannot assign requested address - bind(2) for "172.17.0.2" port 3000 (Errno::EADDRNOTAVAIL)
```

重要なところを切り抜くと。
```
/puma/binder.rb:341:in `initialize': Cannot assign requested address - bind(2) for "172.17.0.2" port 3000 (Errno::EADDRNOTAVAIL)
```
バインドができない。なぜだろうか？一度コンテナ単体で試す。以下を実行。

```bash
docker run --name rails -it -v $(pwd):/home/general_user/rails_dir -p 35729:35729  rails_container:rails_on_jammy
```
この場合、実行できた。docker-compose.ymlのネットワークの設定がだめなのだろうか？

現状のdocker-compose.ymlは以下の通り。

```
version: "3.9"
services:
  rails:
    container_name: rails
    image: rails_container:remake_gu
    volumes:
      - type: bind
        source: ./
        target: /home/general_user/rails_dir
    restart: always
    ports:
      - 35729:35729
      - 3000:3000
    environment:
      BINDING: 172.17.0.2
    tty: true #この行がないとコンテナに入れない。
```
ネットワークの設定をみる。
```bash
$ docker network inspect dev_fc_prototype_default 
[
    {
        "Name": "dev_fc_prototype_default",
        "Id": "ca23e9b0a0dd5e922c3343b6c93d4df5b113a3c44bf1eeebde849fedaca37f42",
        "Created": "2022-12-22T15:59:11.411631882+09:00",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.25.0.0/16",
                    "Gateway": "172.25.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {
            "a820d9cbc1b1c1f5246f5f47fd8e8b0ee07654c0f9d6b7c5f4a64f6bf5825d8a": {
                "Name": "rails",
                "EndpointID": "f8f1d93ce183d53195a1b12239fdfdccb39ebe469d2196989e9963a6038259f6",
                "MacAddress": "02:42:ac:19:00:02",
                "IPv4Address": "172.25.0.2/16",
                "IPv6Address": ""
            }
        },
        "Options": {},
        "Labels": {
            "com.docker.compose.network": "default",
            "com.docker.compose.project": "dev_fc_prototype",
            "com.docker.compose.version": "2.14.1"
        }
    }
]
docker network inspect bridge 
[
    {
        "Name": "bridge",
        "Id": "bd3c4323ad135db0ec95276c92e9b8ea909bd513a8ab69a05841bf38cc1c7140",
        "Created": "2022-12-22T10:34:21.895930622+09:00",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.17.0.0/16",
                    "Gateway": "172.17.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {},
        "Options": {
            "com.docker.network.bridge.default_bridge": "true",
            "com.docker.network.bridge.enable_icc": "true",
            "com.docker.network.bridge.enable_ip_masquerade": "true",
            "com.docker.network.bridge.host_binding_ipv4": "0.0.0.0",
            "com.docker.network.bridge.name": "docker0",
            "com.docker.network.driver.mtu": "1500"
        },
        "Labels": {}
    }
]
```

一応以下メモ。dnsの設定について書いていた。
- [dns｜Compose 仕様｜Docker ドキュメント](https://matsuand.github.io/docs.docker.jp.onthefly/compose/compose-file/#dns)

通常のコンテナの場合サブネットの設定は以下。

```
            "Config": [
                {
                    "Subnet": "172.17.0.0/16",
                    "Gateway": "172.17.0.1"
                }
            ]
```

しかし、composeで作った場合は違う。そのため。compose側でネットワーク設定をしてみるのがいいかもしれない。

ネットワーク設定を追加して試した。以下のエラーが出た。

```
failed to create network rails_network: Error response from daemon: Pool overlaps with other one on this address space
```

設定自体は以下。

```
...
    tty: true #この行がないとコンテナに入れない。
    networks:
      - rails_network

networks:
  rails_network:
    name: rails_network
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 172.17.0.0/16
```

エラーの内容はアドレスが重複しているという内容。なので危険だが、一度ネットワークを削除する。

```bash
docker network rm bridge
```

これを実行すると、事前定義されたネットワークは削除できないと出る。そのため、このネットワーク自体を使う設定がないが確認する。

externalで設定できるそう。しかしエラーが出る。

```
Error response from daemon: network-scoped alias is supported only for containers in user defined networks
```
エイリアスは使っていないのだがなぜだろう？

dockerのネットワークについて学習。

- [【Docker】コンテナとNetworkの関係（Bridgeってなに？名前解決？） - Qiita](https://qiita.com/kenny_J_7/items/77de780d7193b75444c3)

問題が解決していないが、試しに以下を試してみたところ上手く行った。なぜ？

```
    environment:
      BINDING: 172.18.0.2
    tty: true #この行がないとコンテナに入れない。
    networks:
      - rails_network
networks:
  rails_network:
    name: rails_network
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 172.18.0.0/16
```

サブネットでしっかりと設定したからだろうか？

まず、前提として使用されていないIPアドレスを割り当てたことがミソなのだろうか？以前までコンテナのIPアドレスだと思っていたものが実はnetworkのブリッジのIPアドレスだったのだろうか？  
以下確認。

```
cat /etc/hosts
...
172.18.0.2      c7ed5f170632
````

コンテナ内のコンテナIDとIPアドレスの対応をみるとdocker-compose.ymlで設定した通りの設定になっていた。コンテナ作成時にIPアドレスが追加されるという流れだろうか？  
試しに、`docker network inspect rails_network`でみるとデフォルトゲートウェイがなかった。

IPアドレスが固定されていないのが怖いので固定する方法がないか調べる。以下がヒント。

- [docker-composeで固定IPアドレス指定 - Qiita](https://qiita.com/xanadou/items/3abd3d28214dea526084)

上記を参考に公式リファレンスを探す。

- [ipv4_address, ipv6_address｜Compose 仕様｜Docker ドキュメント](https://matsuand.github.io/docs.docker.jp.onthefly/compose/compose-file/#networks)

上記でコンテナのIPアドレスが固定できるそうだ。  
→上手く行った。コンテナのIPアドレスが固定できるようになったので不安な点が少なくなった。

長くなったので一度整理する。  
docker-compose.ymlで以下が可能になった。

1. `docker compose up -d`でコンテナを作成できるようになった。  
（長いdocker runコマンドを書かなくて良くなった）。
1. IPアドレスを明記できた。  
（docker runでも可能だと思うが毎回入力しなくて良くなった）
1. 設定を後から追加しやすくなった。  
（これがおそらく主なメリット。環境変数などを後からつけられるようになった。ちょっとした変更でdockerfileを変更しなくて良くなった。）
1. 他のコンテナを後から追加しやすくなった。  
（docker composeの主な機能？。例えばnginxなどのhttpサーバなどを追加しやすくなった。）

おおよそ上記のことが可能になったと思う。

action cableの許可については解決できていないが、迷走の結果docker composeを導入してプログラム作成が楽になったかもしれない。この点は良かったと感じる。

この段階でできた、`docker-compose.yml`をここに記す。

```docker
version: "3.9"
services:
  rails:
    container_name: rails
    #事前に`docker build -t rails_container:rails_on_jammy .`を実行する。
    image: rails_container:rails_on_jammy
    volumes:
      - type: bind
        source: ./
        target: /home/general_user/rails_dir
    restart: always
    ports:
      - 35729:35729
      - 3000:3000
    environment:
      BINDING: 172.18.0.2
    tty: true #この行がないとコンテナに入れない。
    networks:
      rails_network:
        ipv4_address: 172.18.0.2
networks:
  rails_network:
    name: rails_network
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 172.18.0.0/16
          gateway: 172.18.0.1
```

これでコンテナの方の設定はある程度問題ないと思う。

本題のaction cableの問題に取り掛かる。途中で見つけた以下が参考。

- [3.15 Action Cableを設定する｜Rails アプリケーションを設定する - Railsガイド](https://railsguides.jp/configuring.html#action-cable%E3%82%92%E8%A8%AD%E5%AE%9A%E3%81%99%E3%82%8B)
- [7.2 許可されたリクエスト送信元｜Action Cable の概要 - Railsガイド](https://railsguides.jp/action_cable_overview.html#%E8%A8%B1%E5%8F%AF%E3%81%95%E3%82%8C%E3%81%9F%E3%83%AA%E3%82%AF%E3%82%A8%E3%82%B9%E3%83%88%E9%80%81%E4%BF%A1%E5%85%83)

以前出ていたエラーが許可されていないといった主旨なのでまさしく上記の設定だと思われる。  
（ホスト側で試したときに出なかったエラーだったのでdocker側の問題だと思ったが、そうではなかったという結論に今は至っている。）

ひとまず一番簡単な全部許可する設定を追加する。

その前に、コンテナが消えていたので作成する。

```bash
docker compose up -d
bundle install
```

一度、設定変更前にコミットしておく。("action cableの設定編集前")

設定を追加。

```ruby
config.action_cable.disable_request_forgery_protection = true
```
しかしどこに追加するのだろうか？

---

また、追加で調べていると以下がヒットした。
- [Dockerコンテナの中からホストマシンのlocalhostに接続する方法｜PEblo.gs](https://peblo.gs/get-host-machine-ip-address-in-docker-container/)

どうやらコンテナ側のlocalhostを増やす方法があるそうだ。公式リファレンスを見に行ってみる。

- [extra_hosts｜Compose 仕様｜Docker ドキュメント](https://matsuand.github.io/docs.docker.jp.onthefly/compose/compose-file/#extra_hosts)

試してみる。いまIPアドレスを固定しているので、その次のアドレスを追加する。

なぜこれを今docker側に遡ってするかというと、action cableのrails guideにデフォルトでは`localhost:3000`からのアクセスをすべて許可するとあったので試そうと思った。

追加はできたが、バインドができなかった。また、pingで疎通テストをしたが、届かなかった。そのためこの方法は採用しない。

---

```ruby
config.action_cable.disable_request_forgery_protection = true
```

上記は`development.rb`に追加する。値を`false`にしても上手く行かなかった。  
`application.rb`に書いても上手く行かなかった。

別の書き方を検討する。

正規表現の書き方を確認。
- [Rubular: a Ruby regular expression editor](https://rubular.com/)
- [正規表現：改行コードを含む全ての文字列の表現｜WWWクリエイターズ](https://www-creators.com/archives/2737)

IPアドレス、`172.18.0.2:3000`からのアクセスをすべて許可するために正規表現を作る。以下を使うと上手く当てはまると思う。

```ruby
http:\/\/172\.18\.0\.2:3000\/[\s\S]*
```

上手く行かない。エラーを読み直す。
```bash
10:56:33 web.1        | Started GET "/cable" for 172.18.0.1 at 2022-12-22 10:56:33 +0000
10:56:33 web.1        | Cannot render console from 172.18.0.1! Allowed networks: 127.0.0.0/127.255.255.255, ::1
```
よくみるとIPアドレスが違う？ネットワークアドレスまで合ってたら許可するように追加する。  
→上手く行かない。

- [GitHub - rails/actioncable-examples: Action Cable Examples](https://github.com/rails/actioncable-examples)

上記の場合、依存関係のインストールが必要と冒頭に書かれている。しかし、ホスト側で`redis-cli`や`redis`のコマンドを試してみたがインストールされていない。そのためコンテナ側でも同様であると思う。そのためソフトウェアの不足は本質的な問題ではなさそうである。（エラーの文章にソフトウェアがないといった類のエラーはないと言うのも理由の一つであろう）

github issuesを調べる。
- [Action Cable: Request origin not allowed issue · Issue #31524 · rails/rails · GitHub](https://github.com/rails/rails/issues/31524)
- [Actioncable Allowed Request Origins Ignores -p flag in 5.0.0.rc1 · Issue #25406 · rails/rails · GitHub](https://github.com/rails/rails/issues/25406)

もう少し範囲を広げて調べると以下がヒットした。
- [RailsのActionCableに設定したURL以外から接続する方法 - Qiita](https://qiita.com/gimKondo/items/5f4790bbbc6beaea520e)

これによれば、どうやらrailsガイドにあった書き方は、片方だけで十分というわけではなく、両方必要がと言うことらしい。  
→上手く行かない。

- [GitHub - rails/web-console: Rails Console on the Browser.](https://github.com/rails/web-console#configweb_consolewhiny_requests)

上記に以下のエラーについて言及されている。
```
Cannot render console from 172.18.0.1! Allowed networks: 127.0.0.0/127.255.255.255, ::1
```
このエラーは、web-console側が出しているエラーだそうだ。そのためaction cableのエラーの本質的なところではない。試しに記述通り以下を追加する。

```ruby
config.web_console.whiny_requests = false
```
→確かにエラーがでなくなった。

現状の設定でエラーが出るということはもしかすると認証の問題かもしれない。一度認証が不要な箇所に一時的にスクリプトを追加して確認する。  
→エラーが出る。しばらく認証不要画面で確認する。

別のエラー文を読み直した結果、Syntaxエラーが出ていた。それを修正するとエラーがでなくなった。しかし例外が出てすぐにサーバが閉じてしまう。
しかし、エラーの本質的なところは解消された。エラー文の片側ばかり読んでいたため起きた結果なのでしっかりと反省したい。

新しいエラーは以下の内容。
```
13:03:35 web.1        | #<Thread:0x00007fdbb955eff0 /home/general_user/.rbenv/versions/3.1.2/lib/ruby/gems/3.1.0/gems/actioncable-7.0.4/lib/action_cable/subscription_adapter/redis.rb:150 run> terminated with exception (report_on_exception is true):
13:03:35 web.1        | /home/general_user/.rbenv/versions/3.1.2/lib/ruby/gems/3.1.0/gems/redis-4.8.0/lib/redis/client.rb:398:in `rescue in establish_connection': Error connecting to Redis on localhost:6379 (Errno::EADDRNOTAVAIL) (Redis::CannotConnectError)
```
おそらくこれが元凶と思われるものを取り出した。

長いので重要なところを取り出す。

```
Thread:0x00007fdbb955eff0 terminated with exception (report_on_exception is true) rescue in establish_connection Error connecting to Redis on localhost:6379 (Errno::EADDRNOTAVAIL) (Redis::CannotConnectError)
```

上記を見ていると`cable.yml`でみたURLがあった。以下に示す。
```yml
development:
  adapter: redis
  url: redis://localhost:6379/1
```
とりあえず、ポケットリファレンスの記述に合わせてみる。
```yml
development:
  adapter: async
```
この設定だと問題なく購読が開始された。

はじめの設定は新しい設定だろうか？少し前に試したときは`adapter: async`の設定だったので変わったのだろう。

ひとまず、現状開発時では問題がないと思われるので`adapter: async`の設定で進めていく。

action cableでチャットを送信する前にコードを短縮する工夫をする。

Chatモデルにコールバックをつけて、`Chat.create`を実行して中間テーブルなどの問題を解決するするように瀬底する。  
→と思ったが、返り値のchatモデルインスタンスを使いたいので、通常のインスタンスメソッドにする。

ビュークラス名の認識が間違っていた。action textの多くに`trix-content`がついていてテキストボックス内のエンターを検出できていない。クラス名を変える。単純に`input_space`にする。  
→イベントとの紐付けもOK。確認した。

###### 3.2.3 購読後のjavascriptコードを実装する。

しばらくjavascript周りのコーディングをするのでそのあたりの参考を以下に示す。

- [Element: keypress イベント - Web API｜MDN](https://developer.mozilla.org/ja/docs/Web/API/Element/keypress_event)
- [HTMLFormElement: submit イベント - Web API｜MDN](https://developer.mozilla.org/ja/docs/Web/API/HTMLFormElement/submit_event)
- [&lt;input type="submit"&gt; - HTML: HyperText Markup Language｜MDN](https://developer.mozilla.org/ja/docs/Web/HTML/Element/input/submit)
- [Element: click イベント - Web API｜MDN](https://developer.mozilla.org/ja/docs/Web/API/Element/click_event)
- [【JavaScript】ShiftキーやCtrlキーと同時に押されているキーを取得する方法｜Webエンジニア Wiki](https://web-engineer-wiki.com/javascript/key-multi-push/)
- [KeyboardEvent.shiftKey - Web API｜MDN](https://developer.mozilla.org/ja/docs/Web/API/KeyboardEvent/shiftKey)
- [Action Cable Overview — Ruby on Rails Guides](https://guides.rubyonrails.org/v7.0/action_cable_overview.html#server-side-components-connections)
- [ Action Cable の概要 - Railsガイド](https://railsguides.jp/action_cable_overview.html#%E3%82%B5%E3%83%BC%E3%83%90%E3%83%BC%E5%81%B4%E3%81%AE%E3%82%B3%E3%83%B3%E3%83%9D%E3%83%BC%E3%83%8D%E3%83%B3%E3%83%88)
- [演算子 · JavaScript Primer #jsprimer](https://jsprimer.net/basic/operator/#and-operator)

javascript周りのコードを本や上記リンクを参考に作った。しかし不明点があるので整理していく。

まずaction textのフォームで送信されるデータがどういった形をしているかである。以下のコードで確認する。

```js
    //フォームテキストボックスの要素を取り出す。
    const form_text_box = document.querySelector('#action_text_box');
    //フォームで入力後にshift + Enterで送信する。
    form_text_box.addEventListener('keypress',(event)=>{
      if(event.key==='Enter' && event.shiftKey){
        console.log(event.target.value);//←この行でコンソールに表示。
        event.target.value='';
        return event.preventDefault();
      }
    });
```
これで入力されて、これから送信されようとするデータの形をみる。

結果は以下。内容は適当にしている。

```html
<div>これはテストです。（プレーンなテキスト）<br>アクションテキストは、<strong>太字</strong>や<em>斜体</em>及びその<strong><em>複合</em></strong>、<del>取り消し線</del>が使えます。<br>また、プログラムのコードを書くための機能もあります。</div><pre>#include&lt;stdio.h&gt;
int main(void){
      printf("Hello, World!\n");
      return 0;
}</pre>
```

入力されて、`event.target.value`で補足できる内容はhtmlの断片であることがわかった。  


- [イベントターゲットの比較 - Web API｜MDN](https://developer.mozilla.org/ja/docs/Web/API/Event/Comparison_of_Event_Targets)
- [Event Delegation](https://davidwalsh.name/event-delegate)
- [イベントへの入門 - ウェブ開発を学ぶ｜MDN](https://developer.mozilla.org/ja/docs/Learn/JavaScript/Building_blocks/Events)

つくる方針としては、フォームで`shift+Enter`を押したときにaction cableのイベントを発生させる。また、下にボタンをつけてボタンを押したときに同一のイベントを発生させるようにしたい。

１つ目の`shift+Enter`は簡単に導入できた。しかし、ボタンとイベントの紐付けについてが上手く行かない。知識不足が原因なのでそのあたりを調べる。  
注意すべきは、railsで普通にボタンを作ってしまうとsubmitイベントになってしまうこと。現状の曖昧な知識で予測すると、イベントデリゲーションまたはバブリングといった類の方法で上手く行くと思うのでそのあたりを調べる。

- [イベント伝播｜JavaScript｜イベント操作する上で押さえておきたいポイント(addEventListener) - わくわくBank](https://www.wakuwakubank.com/posts/607-javascript-event/#index_id5)
- [EventTarget.addEventListener() - Web API｜MDN](https://developer.mozilla.org/ja/docs/Web/API/EventTarget/addEventListener)
- [JavaScript｜イベントをコードから発生させる(dispatchEvent)](https://www.javadrive.jp/javascript/event/index13.html)
- [EventTarget.dispatchEvent() - Web API｜MDN](https://developer.mozilla.org/ja/docs/Web/API/EventTarget/dispatchEvent)
- [関数と宣言 · JavaScript Primer #jsprimer](https://jsprimer.net/basic/function-declaration/)

上記を調べていくとdispatchEventを使うと上手く行くかもしれない。

フォーム送信に起きるイベントのターゲットは、`id=chat_text_content`だそうだ。これは何が根拠で決まる？

```html
<trix-editor id="chat_text_content" class="trix-content" ...
```

上記のようなhtml要素がtargetとして得られた。これを取り出すとボタンから起動できそうだ。

- [GitHub - basecamp/trix: A rich text editor for everyday writing](https://github.com/basecamp/trix#editing-text-programmatically)

上記をみるとidを気にするより、直接`trix-editor`を探した方が早そうだ。

動くようにはなったが、入力した文章が取り出せない、ボタンを押しても入力内容が消えないといった問題がある。そのため、イベントオブジェクトにフォーム自体の内容が紐付いていないことがわかる。紐付けを試みる。  
→idやタグで指定してもフォームの外側（<form>)からしか取れない。内側（<trix-editor>）が取れない。

```js
//shift + Enterでイベントを起動したときのeventオブジェクト
keypress Shift { target: trix-editor#chat_text_content.trix-content, key: "Enter", charCode: 0, keyCode: 13 }
//クリックで自作したeventオブジェクト
keypress { target: form#action_text_box.input_space, isTrusted: false, srcElement: form#action_text_box.input_space, currentTarget: form#action_text_box.input_space, eventPhase: 2, bubbles: false, cancelable: false, returnValue: true, defaultPrevented: false, composed: false, … }
```

調べるとkeypressは非推奨になっていたのでkeydownに変更する。
- [Element: keypress イベント - Web API｜MDN](https://developer.mozilla.org/ja/docs/Web/API/Element/keypress_event)

ポケットリファレンスを眺めているとtrix-editorのidがなんとなく上書きできそうだと思った。やってみる。  
→上手く行った。idは自分で決めることもできそうだ。この状態でターゲットを確認するとtrix-editor本体を取り出せた。しかし依然イベントオブジェクトが再現できていない。

一度文字を入力してボタンを押した結果、入力した文字が取り出せた。イベントオブジェクトが同一でないが上手く行った。一旦このまま進める。

空白の入力は困る。サーバ側で対処するのもいいがクライアントでも実装する。（厳密にはjavascripだと何かしらの不具合でイベントを貫通することがあるのでサーバ側でもバリデーションを加える必要がある）  
以下参考。

- [正規表現 - JavaScript｜MDN](https://developer.mozilla.org/ja/docs/Web/JavaScript/Guide/Regular_Expressions)
- [RegExp.prototype.test() - JavaScript｜MDN](https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Global_Objects/RegExp/test)
- [Javascript の正規表現｜WWWクリエイターズ](https://www-creators.com/archives/4488)
- [正規表現チェッカー｜WWWクリエイターズ](https://www-creators.com/tool/regex-checker)
- [タグの中身だけ取り出したい正規表現 - Qiita](https://qiita.com/nemui_yo/items/dea01f0c971bb4c17d20)
- [[正規表現] .*?は最短マッチではない - Qiita](https://qiita.com/anqooqie/items/191ad215e93237c77811)
- [とほほの正規表現入門 - とほほのWWW入門](https://www.tohoho-web.com/ex/regexp.html)
- [JavaScriptで配列の要素を連結して文字列にする：join()｜UX MILK](https://uxmilk.jp/30315)
- [String.prototype.replace() - JavaScript｜MDN](https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Global_Objects/String/replace)

マッチが上手く行かない。以下を試す。
```js
(?<=<.*?>).*?(?=<\/.*?>)
```
色々調べると`.*?`については少し注意がいるが、現状簡単なマッチングで十分（フォームからの入力では単純なhtmlタグだけで属性などは今の所確認できていない）なので上記で問題ないと思う。

- [文字列中の &amp;nbsp; (C2A0) を正規表現で削除 - Qiita](https://qiita.com/hollydad/items/9c0399146415af1912d8)  
空白が上手く消せなかった。上記によれば直接文字コードを指定して削除できるそうだ。  
→上手く行かない。というよりコンソールで確認すると文字化けする。

C2A0を指定するよりも直接打ち込んで変換した方が早いかもしれない。

ひとまず上手く行ったが、一部想定していない動作をする。
```
a a
```
と入力した結果は、
```
aa
```
と処理されることを期待するが、そのまま出てくる。しかしそれ以外の処理はおおよそ上手く行く。現状、空白の入力を許可しないだけなのでOKとし進める。

これで購読時に必要なjavascriptのコードはOK。次はサーバに送信するためのコードとデータ、サーバ側の動作についてである。

##### 3.3 サーバサイドを実装
###### 3.3.1 送信時のクライアントとサーバの連携部分
　サーバに送信するために必要な要素は一応揃った（CSSが当てはめられていなかったり余分な箇所はあるが）。次は、サーバに送信する関数を整理する。

ここまでの作業を一度コミットする（"action cable 購読時動作の草案作成"）

---

念の為、以前に試しに作成したaction textのサンプルでクライアントによって送信されたデータがサーバでどう受信するか確認した。以下内容。

```ruby
p paramsの内容は以下。
#<ActionController::Parameters {"authenticity_token"=>"OSsuHamw406UntWJdA9HpuKcMrvbOuGljvfkvwsbnb2yebXDyV9IIvTbeBl0_Ivl9o2Lkc9mpDahNwewWDbjfQ", "message"=>{"content"=>"<div>表示を確認</div>"}, "commit"=>"Create Message", "controller"=>"messages", "action"=>"create"} permitted: false>
pp params.require(:message).permit(:content) の内容は以下。
#<ActionController::Parameters {"content"=>"<div>表示を確認</div>"} permitted: true>
```

おそらく、`:message`はクラス名から紐付いたもの、`:content`はモデル内で定義した名前。重要な箇所を取り出すと以下。

paramsについては以下。
```ruby
"message"=>{"content"=>"<div>表示を確認</div>"}
```
送信内容にクラス名を使ってハッシュにアクセスすることでデータを取り出すことができる。

インスタンスを作成＆保存するときは以下。
```ruby
#<ActionController::Parameters {"content"=>"<div>表示を確認</div>"}
```
ActionController::Parametersクラスのオブジェクトで、ハッシュに`:content`でアクセスできるようだ。

上記の通りメッセージ自体はhtmlの断片が混じっているが、引数に渡されるのは断片ではなく、`ActionController::Parameters`のオブジェクトである。コンソール上で試してみる。

```bash
./bin/rails c -s #実際には保存したくないのでサンドボックスで実行
a = Message.create(content: "test text")
#<Message:0x00007f2d703db220 id: 15, created_at: Sat, 24 Dec 2022 04:40:18.004036000 UTC +00:00, updated_at: Sat, 24 Dec 2022 04:40:18.012611000 UTC +00:00>
a.content.body
=> #<ActionText::Content "<div class=\"trix-conte..."> 
Message.first.content.body
=> #<ActionText::Content "<div class=\"trix-conte..."> 
```

内容としてはブラウザから作った内容と同じものを作るには、`Message.create(content: "test text")`の記述で作成できそうだ。  
(現在確認できる範囲では、`ActionController::Parameters`のオブジェクトを引数に渡したのと動作が同じ。)

---

一度現状のコードで送信してみる。以下のエラーが出た。(ディレクトリのパスは消しておく。長いので。)

```ruby
05:01:38 web.1        | RoomChannel#speak({"content"=>"<div>aa</div>"})
05:01:38 web.1        | Could not execute command from ({"command"=>"message", "identifier"=>"{\"channel\":\"RoomChannel\"}", "data"=>"{\"content\":\"<div>aa</div>\",\"action\":\"speak\"}"}) [ArgumentError - When assigning attributes, you must pass a hash as an argument, String passed.]: /attribute_assignment.rb:30:in `assign_attributes' | /active_record/core.rb:468:in `initialize' | /active_record/inheritance.rb:75:in `new' | /active_record/inheritance.rb:75:in `new' | /active_record/persistence.rb:54:in `create!'
```

以前のようなシンタックスエラーはない。出ているのは`ArgumentError`なのでサーバ側の引数が変かもしれない。一度ターミナルで試す。

```bash
./bin/rails c -s
a = ChatText.create(content: "test text")
=> #<ChatText:0x00007fbb852510a0 id: 10, created_at: Sat, 24 Dec 2022 05:14:14.852734000 UTC +00:00, updated_at: Sat, 24 Dec 2022 05:14:14.987044000 UTC +00:00>
```
上手くは行く。

dev consoleで表示してみる。

```
05:17:09 web.1        | RoomChannel#speak({"content"=>"<div>aa</div>"})
05:17:09 web.1        | {"content"=>"<div>aa</div>", "action"=>"speak"} #←クライアントから直接送られるものを表示。
05:17:09 web.1        | "<div>aa</div>" #←クライアントから送られてきたデータ（data)のハッシュを取り出したもの。data["content"]
```

そのため、今のコードでは直接htmlの断片を引数に渡すことになっている。これはエラーの元だと思う。以下に示す。コンソール上で実行。

```ruby
a = ChatText.create("test text")
/active_model/attribute_assignment.rb:30:in `assign_attributes': When assigning attributes, you must pass a hash as an argument, String passed. (ArgumentError) 
```

直接文字列を渡すとエラーになる。そのためハッシュにする。

小ネタ：Guardfileに日本語を含めるとエラーが出る。英語で書くこと。

修正すると、アーギュメントエラーはでなくなりトランザクションが開始された。しかし、別のエラーが出た。原因はおおよそわかっているのでいかに示す。

```ruby
chat_text = ChatText.create!(content: data["content"]) #←この文は問題ないはず
chat = chat_text.set_chat_table #←このメソッドがまずい。
```

`set_chat_table`は中間テーブルにレコードを追加するためにモデルに直接書いたメソッド。以下に示す。

```ruby
    #中間テーブルに追加をして参照できるようにする。
    def set_chat_table
        user = session[:user]
        room = Room.find(params[:id])
        chat = Chat.create(user: user, room: room, chat_text: self)
    end
```

色々試すと、action cableではsessionが使えなかったことを思い出した。

まず、疎通ができることを確認する。サーバ側のコードとクライアント側のコードを示す。

```ruby
#サーバ側。
  #クライアント側の挙動で呼び出される
  def speak(data)
    chat_text = ChatText.create!(content: data["content"])
    ActionCable.server.broadcast(
      "room_channel", { content: data["content"]}
    )
  end
```
```js
//クライアント側
  received(data) {
    // Called when there's incoming data on the websocket for this channel
    console.log(data);
  }
```

これでクライアントで送信したデータをサーバが受信し、受信したデータをそのままブロードキャストする。ブロードキャストして受け取ったデータをクライアントのコンソールに表示する。  
→フォームに`aaa`と入力して送信。ターミナルで確認すると`Object { content: "<div>aaa</div>" }`が受信される。  
→OK疎通テストはOK。送受信は成功。後は受信内容を元に処理を加えてレンダリングする。

---
<br>
メモ： `Object { content: "<div>aaa</div>" }`  
ブラウザのコンソールで以下を入力すると同一の結果を得られる。

```js
obj = { content: "<div>aaa</div>" }
//=>Object { content: "<div>aaa</div>" }
```

---

動作を確認しやすくするためにテストを書く。ChatTextモデルのテストファイルにコードを追加して動作を確認する。

###### 3.3.2 サーバサイドのテストによる動作確認の準備
テストを試そうとしたところフィクスチャのエラーが出る。公式リファレンスを読む。
- [ActiveRecord::FixtureSet](https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html)

どうやらテストではフィクスチャを使うようだ（初期データの投入だけだと思っていた）。

コンソールでテスト環境状態を確認する。

```bash
./bin/rails c -s -e test
```
なにか変。

一度データベースを作り直す。

```bash
./bin/rails db:drop RAILS_ENV=test
./bin/rails db:create RAILS_ENV=test
./bin/rails db:migrate RAILS_ENV=test
```

上記のようにしてもいいが、テストの場合以下でもできるそうだ。

```bash
./bin/rails db:test:purge
./bin/rails db:test:load
```

フィクスチャファイルを修正してテストデータを投入する。

```bash
./bin/rails db:fixtures:load FIXTURES=users RAILS_ENV=test
```
上記のように一つづつ入れてエラーの元を特定する。  
→リファレンスの通り、ラベルを使ってアソシエーションのフィクスチャを作成していたがそれがエラーの元だった。

以下にUserRoomモデルのフィクスチャファイルを示す。

```yml
#user_rooms.yml
nkun_room:
  user_id: 1
  room_id: 1

xsan_room:
  user_id: 2
  room_id: 2

ysan_room:
  user_id: 3
  room_id: 3
```

これに修正すれば以下で単純に流し込みできるようになった。これでテストができるはず。
```bash
./bin/rails db:fixtures:load RAILS_ENV=test
```

これでテスト環境だけ変更できた（development環境は変わっていないはずなのでブラウザからは変わらないはず）。  
テストコードを実行する。  
(action textのテストデータは複雑なので今は、テストコードからnewした方が楽と思い、今回は記述しない。)

次を試しにテスト。

```ruby
  #インスタンスの生成を共通化する。
  def setup
    @chat_text = ChatText.create(content: "<div>test text</div>")
    @user = User.find(1)
    @room = Room.find(1)
  end
  #インスタンスの削除を共通化する。
  def teardown
    ChatText.destroy(@chat_text&.id)
  end
  #定義したインスタンスの状態を確認する。
  test "check instance variable" do
    assert true
    assert @chat_text, "newに失敗しました。"
    assert @user     , "ユーザが見つかりませんでした。"
    assert @room     , "ルームが見つかりませんでした。"
    p "インスタンスを表示"
    p @chat_text
    p @user
    p @room
  end
```
結果は以下。

```ruby
./bin/rails test test/models/chat_text_test.rb 
Running 1 tests in a single process (parallelization threshold is 50)
Run options: --seed 25164                                           
                                                                    
# Running:                                                          
                                                                    
"インスタンスを表示"            
#<ChatText id: 1, created_at: "2022-12-25 04:33:19.128453000 +0000", updated_at: "2022-12-25 04:33:19.247433000 +0000">
#<User id: 1, user_name: "nkun", password: [FILTERED], created_at: "2022-12-25 04:33:18.989880000 +0000", updated_at: "2022-12-25 04:33:18.989880000 +0000">
#<Room id: 1, room_name: "nkun", created_at: "2022-12-25 04:33:18.987510000 +0000", updated_at: "2022-12-25 04:33:18.987510000 +0000">
.                               
                                
Finished in 0.470289s, 2.1264 runs/s, 8.5054 assertions/s.
1 runs, 4 assertions, 0 failures, 0 errors, 0 skips
```

OK想定していた動作をしている。これでテストを実行できるようになった。

---

小ネタ（後から検索しやすくするために）：  
少なくとも、モデルテストではフィクスチャ(fixture)ファイルをしっかりと用意しないとテストが動作しない。

---

上記のテストの書き方が見返すと変だったので修正。


```ruby
 #インスタンスの生成を共通化する。
  def setup
    @chat_text = ChatText.create content: "<div>test text</div>"
    @user = User.find(1)
    @room = Room.find(1)
    @chat = Chat.create user: @user, room: @room, chat_text: @chat_text
  end
  #インスタンスの削除を共通化する。
  def teardown
    #中間テーブルを先に削除しないとエラーが出る。
    #もしかすると自動で消えるかもしれないが、念の為明示的に削除する。
    Chat.destroy(@chat.id)
    ChatText.destroy(@chat_text.id)
  end
  #定義したインスタンスの状態を確認する。
  test "check instance variable" do
    assert @chat_text
    assert @user
    assert @room
    assert @chat
  end

#以下結果。

./bin/rails test test/models/chat_text_test.rb 
Running 1 tests in a single process (parallelization threshold is 50)
Run options: --seed 10021

# Running:

.

Finished in 0.348086s, 2.8729 runs/s, 11.4914 assertions/s.
1 runs, 4 assertions, 0 failures, 0 errors, 0 skips
```

ポケットリファレンスを読むとデータベースのクリアは自動でされるそうだ。そのためteardownを削除する。

###### 3.3.3 action cableの挙動について

関数の機能が正しく動作することを確認した。

また、action cableのテストもできるそうなので、そっちで確認したほうが便利かもしれない。以下参考。

- [ActionCable::Channel::TestCase](https://api.rubyonrails.org/classes/ActionCable/Channel/TestCase.html)

メソッドについてメモする。

---

小ネタ：  
action cableのテストではhttpメソッドは使えなそう。

---

action cableで認証を有効にするには`identified_by`が必要だそうだ。現状つけていないので認証を貫通してブロードキャストされるはずだ。

いま、送信内容を送信者と送信場所と紐付けようとしている。現在は送信内容を保存することには成功している。

テスト側で、識別情報をセットしてそこから送信場所と送信者を特定することができないかテストしてみる。  
→テスト側だけでは不十分。このタイミングで認証を追加するが認証を追加する前に、クライアントで受信結果を描画できるようにする。

ルームとユーザを特定するためにはやはりクッキーを使うしかない。クッキーにidを保存する動作をコントローラで実装する。  
→それをが正しく保存されているかテストをして確認→OKきちんと保存されていた。しかし保存内容はintegerではなくstringになっている点に注意。

action cableのコードにそれらを使ったコードを追加し描画できるようにする。

action cableのテストについては以下。
- [ActionCable::Channel::TestCase::Behavior](https://api.rubyonrails.org/classes/ActionCable/Channel/TestCase/Behavior.html#method-i-stub_connection)
- [ActionCable::Channel::ConnectionStub](https://api.rubyonrails.org/classes/ActionCable/Channel/ConnectionStub.html)

action cableの認証については以下。
- [8.3 メモ｜Action Cable の概要 - Railsガイド](https://railsguides.jp/action_cable_overview.html#%E3%83%A1%E3%83%A2)
> action cableではセッションにアクセスできないがクッキーにはアクセス可能であることが書かれている。
- [ActionCable Devise Authentication｜Greg Molnar](https://greg.molnar.io/blog/actioncable-devise-authentication/)
> 上記の詳細について書かれているらしい。

試してみたところ、チャネルからクッキーにアクセスできない。よく見たところ、connection側？に書かれていることがわかる。action cableについて理解が足りていないので一度ポケットリファレンスの概要をもう少し読む。  
→コネクションはクライアント（サブスクライバ）とサーバ （チャネル）を接続する部分。そのためクッキーが見えないのはチャネルからみるとクライアントではなくコネクションが見えるからだと考えられる。そのためコネクションからだとクライアントが見えると予想される。

コネクションにクッキーを読めるようにする。

しかし概要を読んでいてもコネクションがわからない。以下にデフォルトを示す。

```ruby
module ApplicationCable
  class Connection < ActionCable::Connection::Base
  end
end
```

リファレンスには、このクラスに`connect`と`disconnext`を定義している。
- [ActionCable::Connection::Base](https://api.rubyonrails.org/classes/ActionCable/Connection/Base.html)

試しに以下を書いてテストでサブスクライブしてみる。
```ruby
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    def connect
      p "---------------------------------------------------------"
      p "now app/channels/application_cable/connection.rb"
      p "connection start"
      p "---------------------------------------------------------"
    end
  end
end

```

テストコードは以下。

```ruby
  #connectionテスト
  test "check connection" do
    subscribe
  end
```
購読によって`connect`が実行される特別な名前とすれば文字列が表示されるはず。  
→`./bin/rails test test/channels/room_channel_test.rb -n "check connection"`で実行したが何も表示されない。なぜだ？

```ruby
13:57:31 web.1        | Started GET "/cable" for 172.18.0.1 at 2022-12-25 13:57:31 +0000
13:57:31 web.1        | Cannot render console from 172.18.0.1! Allowed networks: 127.0.0.0/127.255.255.255, ::1
13:57:31 web.1        | Started GET "/cable" [WebSocket] for 172.18.0.1 at 2022-12-25 13:57:31 +0000
13:57:31 web.1        | Successfully upgraded to WebSocket (REQUEST_METHOD: GET, HTTP_CONNECTION: keep-alive, Upgrade, HTTP_UPGRADE: websocket)
13:57:31 web.1        | "---------------------------------------------------------"
13:57:31 web.1        | "now app/channels/application_cable/connection.rb"
13:57:31 web.1        | "connection start"
13:57:31 web.1        | "---------------------------------------------------------"
13:57:31 web.1        | RoomChannel is transmitting the subscription confirmation
13:57:31 web.1        | RoomChannel is streaming from room_channel
```
コンソールをみると上記の描画があった。`connect`は購読が始まった後に実行されるようだ。(特別な名前のよう。)   
→テストで呼び出せないのか？

コネクションに関してはテストが別らしい。以下参考。
- [ActionCable::Connection::TestCase](https://api.rubyonrails.org/classes/ActionCable/Connection/TestCase.html)
- [rails/base.rb at master · tongueroo/rails · GitHub](https://github.com/tongueroo/rails/blob/master/actioncable/lib/action_cable/connection/base.rb)  
 GitHubのリポジトリは上記

- [ActionCable::Connection::TestCase](https://api.rubyonrails.org/classes/ActionCable/Connection/TestCase.html)  
 コネクションのテストの概要。
- [ActionCable::Connection::TestCase::Behavior](https://api.rubyonrails.org/classes/ActionCable/Connection/TestCase/Behavior.html)  
 コネクションのテストで使えるメソッド。

上記を参考に簡単に以下を記述。

```ruby
  #コネクションの開始を確認する。
  test "check start connection" do
    connect
  end
```
結果は以下。
```ruby
 ./bin/rails test test/channels/application_cable/connection_test.rb 
Running 1 tests in a single process (parallelization threshold is 50)
Run options: --seed 30503

# Running:

"---------------------------------------------------------"
"now app/channels/application_cable/connection.rb"
"connection start"
"---------------------------------------------------------"
.

Finished in 0.295367s, 3.3856 runs/s, 0.0000 assertions/s.
1 runs, 0 assertions, 0 failures, 0 errors, 0 skips
```

コネクション作成時の挙動を確認できた。一応反対の`disconnect`も確認する。  
→これも切断時に動作することがわかった。

しかし疑問は、コネクションとサブスクリプションが別だということ。コネクションがないとサブスクリプションが起きないのに、テストではなぜコネクションのメソッドが表示されないのだろうか？もしくは認識が逆なのだろうか？

試しにsubscribeメソッドにメッセージを表示させた。以下にコンソール出力を示す。

```ruby
14:38:17 web.1        | Started GET "/cable" for 172.18.0.1 at 2022-12-25 14:38:17 +0000
14:38:17 web.1        | Cannot render console from 172.18.0.1! Allowed networks: 127.0.0.0/127.255.255.255, ::1
14:38:17 web.1        | Started GET "/cable" [WebSocket] for 172.18.0.1 at 2022-12-25 14:38:17 +0000
14:38:17 web.1        | Successfully upgraded to WebSocket (REQUEST_METHOD: GET, HTTP_CONNECTION: keep-alive, Upgrade, HTTP_UPGRADE: websocket)
14:38:17 web.1        | "-------------------------------------------------------------"
14:38:17 web.1        | "now app/channels/application_cable/connection.rb:connect"
14:38:17 web.1        | "connection start"
14:38:17 web.1        | "-------------------------------------------------------------"
14:38:17 web.1        | "sbuscribed"
14:38:17 web.1        | RoomChannel is transmitting the subscription confirmation
14:38:17 web.1        | RoomChannel is streaming from room_channel
```
上記の通り、サブスクライブはコネクションの後に起きる。  
考察：これは単純にテストを独立して実行するためのもの？独立していないとテストする上では厄介だからコネクションが発生しない。そう感じる。

変数などがどうつながっているか？スコープが謎だったので表示して確認した。

```ruby
#connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :online_user#←これがミソらしい
    def connect
      p "-------------------------------------------------------------"
      p "now app/channels/application_cable/connection.rb:connect"
      p "connection start"
      p "-------------------------------------------------------------"
      self.online_user = "user_online" #←ここで変数?に代入。
    end
  end
end

#room_channel.rb(サブスクライブ時にコンソール表示。)
  def subscribed
    stream_from "room_channel"
    p "sbuscribed"
    p online_user#←チャネルインスタンス作成時に自動的に生成される。
  end

#結果
02:54:22 web.1        | Started GET "/cable" for 172.18.0.1 at 2022-12-26 02:54:22 +0000
02:54:22 web.1        | Cannot render console from 172.18.0.1! Allowed networks: 127.0.0.0/127.255.255.255, ::1
02:54:22 web.1        | Started GET "/cable" [WebSocket] for 172.18.0.1 at 2022-12-26 02:54:22 +0000
02:54:22 web.1        | Successfully upgraded to WebSocket (REQUEST_METHOD: GET, HTTP_CONNECTION: keep-alive, Upgrade, HTTP_UPGRADE: websocket)
02:54:22 web.1        | "-------------------------------------------------------------"
02:54:22 web.1        | "now app/channels/application_cable/connection.rb:connect"
02:54:22 web.1        | "connection start"
02:54:22 web.1        | "-------------------------------------------------------------"
02:54:22 web.1        | Registered connection (user_online)
02:54:22 web.1        | "sbuscribed"
02:54:22 web.1        | "user_online"
02:54:22 web.1        | RoomChannel is streaming from room_channel
02:54:22 web.1        | RoomChannel is transmitting the subscription confirmation
```

- [ActionCable::Connection::Identification::ClassMethods](https://api.rubyonrails.org/v7.0/classes/ActionCable/Connection/Identification/ClassMethods.html#method-i-identified_by)  
identified_byについては上記。これに関する説明は以下。
> (原文)Mark a key as being a connection identifier index that can then be used to find the specific connection again later. Common identifiers are current_user and current_account, but could be anything, really.  
Note that anything marked as an identifier will automatically create a delegate by the same name on any channel instances created off the connection.   
(機械翻訳)キーを接続識別子のインデックスとしてマークし、後で特定の接続を検索するために使用することができます。一般的な識別子は current_user と current_account ですが、実際には何でもかまいません。 
識別子としてマークされたものは、その接続から作成されるすべてのチャンネルインスタンスに自動的に同じ名前のデリゲートを作成することに注意してください。

上記に合わせて`user_online`を`current_user`にしておく。

---
<br>
ここまででaction cableの挙動についてすこしまとめる。推測を含むが抽象的に理解するためであるのでその点は問題にしない。  
わかった段階で理解を修正すればよいと考えるため、現時点での理解をまとめていく。

まず、処理の流れについて。

1. action cableの開始
1. コネクションの開始(WebSocket)
1. コネクションのインスタンスを生成
1. コネクションのインスタンスメソッド、connectを実行。
1. identified_byで指定されたキーの処理を実行。
1. 購読の開始。
1. ストリームの作成。
1. 双方向通信が可能な状態になる。

雑だが、上記の流れで処理される。  
（親チャネルに対して挙動の確認をしていないので全容ではないが最低限使う分には十分だろう）。

---

`user_online`の記述位置（クッキーが使える位置）がわかったので、action cableでユーザを特定する方法を追加する。

クッキーが使えることは以下でわかる。
- [ActionCable::Connection::Base](https://api.rubyonrails.org/classes/ActionCable/Connection/Base.html#method-i-cookies)

試しにクッキーの中身を表示してみる。

```ruby
    def connect
      #コネクション開始時にクッキーから認証情報を取り出す。
      self.current_user = "user_online"
      self.current_room = "room_online"
      p "cookies[:user_info]=#{cookies[:user_info]}"
      p "cookies[:room_info]=#{cookies[:room_info]}"
    end
#結果
03:40:04 web.1        | "cookies[:user_info]=1"
03:40:04 web.1        | "cookies[:room_info]=1"
03:40:04 web.1        | Registered connection (room_online:user_online)
```

使えることは確認できた。中身もOK。

railsガイドを読んでいてはじめて知ったが、find_by(id: xxx)というメソッドやfindメソッドはidに文字を入れてもOKだということを知った。そのためクッキー内の情報をそのまま使えることがわかった。これを利用する。

認証に失敗したときのメソッドを調べる。以下。
- [ActionCable::Connection::Authorization](https://api.rubyonrails.org/v6.1.4/classes/ActionCable/Connection/Authorization.html#method-i-reject_unauthorized_connection)  
失敗したら404を返すそうだ。

認証の処理を追加して、ユーザとルームを特定、それぞれのインスタンスを`identified_by`に渡してサブスクライブ時に使えるようにした。

これで、サブスクライブ時にユーザ情報とルーム情報が使えるようになった。

###### 3.3.4 動作確認
上記までで、以下が整った。

1. action cable疎通テスト（データの送受信を確認、内容も）
1. 送信内容の保存確認（ユーザ情報を直接サブスクライブ時に保存した状態で確認）
1. 再描画確認（送信内容を描画し、それをブラウザで更新されるか確認）
1. クッキーからユーザ情報を取り出して認証（直前で確認）

そのため一度ブラウザからデータを送信し挙動を確認した。  
→上手く動作した。最低限動くようになった。

クッキーについて不明点が多いので以下参考。
- [ActionDispatch::Cookies](https://api.rubyonrails.org/classes/ActionDispatch/Cookies.html)

#### 4. プロトタイプの作成完了
　機能が不十分であったり実装が足りていないところはある。しかしプロトタイプとしては十分であると判断したため一度ここでイテレーション１のプロトタイプ作成を終了とする。

現在までにできたものを一度リモートにプッシュして保存しておく。また、以前はプロトタイプで作ったものを元にメインブランチで別に作ろうと考えていた。しかし、かなり規模が大きくなったため位置から書くのは良くないと考えた。

そのため、プロトタイプとメインブランチをマージしてメインブランチで続きの調整をする。

#### 5. メインブランチでの作業
　これ以降の作業はブランチをマージして、プロトタイプのコードをメインブランチに移し行う方が良いと思う。また、このファイルも現在三千行を超えているのでgithubアクションの消費量が大きくなる可能性がある。そのため別ファイルで記録をつけていく。

以下リンクである。

- [イテレーション1 メインブランチでの作業]({{site.baseurl}}/iteration_1/main_branch)