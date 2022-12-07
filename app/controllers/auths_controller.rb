class AuthsController < ApplicationController
  before_action :basic_auth, only: :login
  before_action :keep_login, only: :mypage
  # showメソッドはログイン状態で実行する
  def show
  end
  # ログインを検証
  def login
  end
  # ログイン状態を破棄する
  def logout
    #セッションを破棄する
    set_session user_name: nil, password: nil
    set_session user: nil
    #p session[:user]
    redirect_to url_for action: 'show'
  end
  #新規ユーザの登録
  def new
    #フォームへの入力で以下の宣言が必要
    @user = User.new
  end
  #ログイン後の画面
  def mypage
    #@user = session[:user]
    #p session
    #p session[:user]
    #セッションのハッシュからインスタンスを再構成するには以下のコードを記述する。
    @user = User.new session[:user]
    #p session[:authenticated]
    #p @user
  end

  #情報の登録
  def create
    #ユーザを作成
    @user = User.new(user_info)
    #同一ユーザを検索して表示。同一名のユーザは存在を許さないため必ず0 or 1つのレコードが検出される。
    @user_exist = User.find_by(user_name: @user.user_name)
    #もしすでに同一名のユーザが存在した場合。ログインホームにリダイレクトする。
    return redirect_to url_for action: 'show' unless @user_exist.nil?
    
    #新規ユーザの場合データベースに登録する。
    if @user.save
      #登録に成功した場合、登録してマイページに移動する。
      redirect_to url_for action: 'mypage' #, flash: { user: @user }
    else
      #失敗した場合、入力画面に戻る。
      redirect_to url_for action: 'new'
    end
  end

  private
  def basic_auth
    #基本認証
    #認証結果をstatusに格納する
    authenticate_or_request_with_http_basic('Application') do |name, pw|
      # すでにログイン済みの場合
      #この書き方は良くない。間違ったパスワードでも入れてしまう。
      #if session[:user_name]&.eql?(name)
      #  #@user = User.find_by(user_name: name)
      #  #return render 'mypage', user: @user
      #  return redirect_to url_for action: 'mypage' #, flash: { user: @user }
#
      #  #すでに認証済みの場合
      #end

      #ログイン済みの場合、別の書き方
      #user_exist = User.new session[:user]
      #user_on_db = User.find_by(user_name: name)
      #unless user_on_db.user_name&.eql?(user_exist.user_name)
      #end

      # user_nameとpasswordをセッションに保存する。
      #session[:user_name] = name
      #session[:password]  = pw

      # user_nameとpasswordをセッションに保存する。
      # set_session user_name: name, password: pw
      # ユーザ名に該当するユーザを検索（同一名のユーザは許容しないとする) 
      @user = User.find_by(user_name: name)
      # ユーザがいなければ失敗を返す
      if @user&.nil?
        #session[:user_name]=nil
        #session[:password] =nil
        # return render 'show'
        #セッションを破棄する
        #set_session user_name: nil, password: nil
        set_session user: nil

        #redirect_to url_for action: 'show'
        #ユーザが存在しない場合、失敗を返す。
        return false
      end
      # ユーザが存在するときパスワードが正しいか検証する。
      if @user&.password.eql?(pw)
        # 認証が成功した場合、マイページを表示する
        # render 'mypage', user: @user 
        #セッションを設定
        #set_session user_name: @user.user_name, password: @user.password
        set_session user: @user
        #p session[:user]
        #p @user
        #redirect_to url_for action: 'mypage' #, flash: { user: @user }
        # return true
        return false
      else
        # 認証に失敗した場合もとのページを表示する。
        #session[:user_name]=nil
        #session[:password] =nil
        #render 'show'
        #セッションを破棄する
        #set_session user_name: nil, password: nil
        set_session user: nil
        #redirect_to url_for action: 'show'

        #パスワードの認証に失敗した場合falseを返す。
        return false
      end
      #問答無用で失敗させる
      return false
    end

    #statusが401なら認証に失敗
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

  #ログイン状態でのみアクセスを許可するように処理する。
  def keep_login
    #セッション内にユーザ情報を保持し（別メソッドで）、セッション情報を元にログイン状態を維持する。
    #セッションからユーザ情報を取り出す。
    user_login = User.new session[:user]
    p user_login
    unless user_login.user_name&.nil?
      #ユーザ情報がある場合、認証を試みる。
      p 'start auth'
      p user_login.user_name
      p user_login.password
      #http_basic_authenticate_or_request_with name: user_login.user_name, password: user_login.password, realm: 'Application'
      request.headers['Authorization'] = ActionController::HttpAuthentication::Basic.encode_credentials(user_login.user_name,user_login.password)
    else
      #セッション内にユーザ情報がない場合、リダイレクトor描画を許可しない。
      return false
    end
  end
end
