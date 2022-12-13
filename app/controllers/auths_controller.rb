class AuthsController < ApplicationController
  before_action :basic_auth, only: [:mypage]
  before_action :empty_auth, only: [:logout]

  #showメソッドはログインとアカウント作成を選択する画面を表示する。
  def show
  end
  # ログイン情報を上書き
  def logout
    #ログアウトしたページは専用のユーザのみが見られるようにする
    #専用ユーザをログアウトユーザorエンプティユーザとする
    #処理の本体はempty_authsに託している。このメソッドはルーティングとの紐付けと画面表示のためにある。
  end
  #新規ユーザの登録
  def new
    #フォームへの入力で以下の宣言が必要
    @user = User.new
  end
  # ログインを検証しマイページを表示する。
  def mypage
    @user = session[:user]
  end

  #POST時に生じる処理。
  #情報の登録
  def create
    #ユーザを作成
    user = User.new(user_info)
    #同一ユーザを検索して表示。同一名のユーザは存在を許さないため必ず0 or 1つのレコードが検出される。
    user_exist = User.find_by(user_name: user.user_name, password: user.password)
    #もしすでに同一名のユーザが存在した場合。ログインホームにリダイレクトする。
    return redirect_to url_for action: 'mypage' unless user_exist.nil?
    #偽認証の情報と同一の場合、失敗するように設定する。入力し直しのためにnew画面に戻す。
    return redirect_to url_for action: 'new' if user.user_name.eql?("WT5CZXGqkwLuv05D")
    
    #新規ユーザの場合データベースに登録する。
    if user.save
      #登録に成功した場合、登録してマイページに移動する。
      session[:user] = user
      #認証情報をヘッダに付与してリダイレクトする。
      redirect_to url_for(action: 'mypage', only_path: false, user: user.user_name, password: user.password)
    else
      #失敗した場合、入力画面に戻る。
      redirect_to url_for action: 'new'
    end
  end

  private
  def basic_auth
    #基本認証
    #初回ログイン時とログイン状態の維持に使う。
    #初回ログイン時はsession内にユーザ情報がない。そのため初回ログイン時はsessionに情報を保存する。
    #ログインの維持にはsession情報で維持したい。←　明記するのはログアウトでしっかりと情報を破棄するため
    #ログアウトに関する認識の変化。ログアウトは情報の破棄でなく、無効な認証情報で上書きすること。
    #無効な認証情報の第一候補は空白の名前とパスワードだが、空白で認証できずにセッションが維持される可能性がある。
    #そのため特別な名前を考えて登録しておくのがいいだろうか？　
    authenticate_or_request_with_http_basic('Application') do |name, pw|
      #ブロックを抜けるにはreturnではなくnext
      #next false if true

      #アカウントを保持していて、ユーザ名とパスワードを入力した状態で以下の処理が始まる。
      #すでにログイン済みの場合は特に記述する必要はない。
      #キャッシュでログインがクリアできる。

      #アカウントの認証
      user = User.find_by(user_name: name, password: pw)
      #ユーザ名とパスワードの組のユーザが存在しなければ失敗を返す。
      next false if user.nil?

      #セッションにユーザの情報を保存する
      session[:user] = user
    end
  end

  #POST時のPOST内容を表示する
  def user_info
    params.require(:user).permit(:user_name, :password)
  end

  #セッションの設定
  def set_session hash_list={}
    hash_list&.each do |key,value|
      session[key]=value
    end
  end

  #空白で認証を許可し、キャッシュを上書きする。
  #javascriptで空のユーザと空のパスワードのヘッダを送る。
  def empty_auth
    #ユーザ名とパスワードを空欄にして認証させる
    #request.headers['Authorization'] = ActionController::HttpAuthentication::Basic.encode_credentials("","")
    #空白の情報でわざと認証を成功させる
    authenticate_or_request_with_http_basic('Application') do |name, pw|
      if name=="WT5CZXGqkwLuv05D" && pw=="WT5CZXGqkwLuv05D"
        #request.reset_session
        session[:user] = nil
        next true
      else
        next false
      end
    end
  end
end
