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
[プロトタイプ]({{site.baseurl}}/iteration_1/prototype)で得られた結論に至る過程を知る必要があれば以下を読み進めることを推奨する。不要の場合は非常に長いため読まないことを推奨する。

以下作業記録である。

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

##### 1.6 ルーティング
　コードを作りながら以下のルーティングを決定した。

|URL|http method|controller#action|表示内容・動作内容|
|-|-|-|-|
|/auths|GET|auths#show|ログイン・アカウント作成の選択。|
|/auths|POST|auths#create|新規アカウントの発行。|
|/auths/new|GET|auths#new|新規アカウント作成画面を表示。ユーザ名とパスワードを入力して`/auths`に`POST`する。|
|/auths/login|GET||ログインのために認証情報を入力して認証の準備をする。|

##### 1.6 下調べリスト
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
- 
- 

#### 2. テキスト入力

###### 1.4.中間テーブルについて

　railsでは多対多を実装する方法として２つあるそうだ。以下に示す。  
1. `has_and_belongs_to_many`  
1. `has_many assoc_id, through: middle_id`

しかし、1は制約が多いためできるだけ2を使うことが推奨されているそうだ。そのため本件でも2の方法を使用する。

#### 3. 履歴表示