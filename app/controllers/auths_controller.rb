class AuthsController < ApplicationController
  before_action :basic_auth, only: :login
  # showメソッドはログイン状態で実行する
  def show
  end
  # ログインを検証
  def login
  end
  # ログイン状態を破棄する
  def logout
    redirect_to url_for action: 'show'
  end
  #新規ユーザの登録
  def new
    #フォームへの入力で以下の宣言が必要
    @user = User.new
  end
  #ログイン後の画面
  def mypage
    @user = flash[:user]
  end

  #情報の登録
  def create
    @user = User.new(user_info)
    @user_exist = User.find_by(user_name: @user.user_name)
    return redirect_to url_for action: 'show' unless @user_exist.nil?
    respond_to do |f|
      if @user.save
        f.html { render :mypage, user: @user }
      else
        f.html { render :new }
      end
    end
  end

  private
  def basic_auth
    authenticate_or_request_with_http_basic('Application') do |name, pw|
      # すでにログイン済みの場合
      if session[:user_name].eql?(name)
        @user = User.find_by(user_name: name)
        #return render 'mypage', user: @user
        return redirect_to url_for action: 'mypage', flash: { user: @user }
      end
      # user_nameとpasswordをセッションに保存する。
      session[:user_name] = name
      session[:password]  = pw
      # ユーザ名に該当するユーザを検索（同一名のユーザは許容しないとする) 
      @user = User.find_by(user_name: name)
      # ユーザがいなければ失敗を返す
      if @user.nil?
        session[:user_name]=nil
        session[:password] =nil
        # return render 'show'
        return redirect_to url_for action: 'show'
      end
      # ユーザが存在するときパスワードが正しいか検証する。
      if @user.password.eql?(pw)
        # 認証が成功した場合、マイページを表示する
        # render 'mypage', user: @user 
        redirect_to url_for action: 'mypage', flash: { user: @user }
      else
        # 認証に失敗した場合もとのページを表示する。
        session[:user_name]=nil
        session[:password] =nil
        #render 'show'
        redirect_to url_for action: 'show'
      end
    end
  end

  def user_info
    params.require(:user).permit(:user_name, :password)
  end

  #クッキーの設定
end
