class AuthsController < ApplicationController
  #ログイン認証
  before_action :basic_auth, only: [:mypage]
  #ログアウト処理
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
    
    #ユーザ名に対応するひとり言ルームを同時に作成する。
    room = Room.new(room_name: user.user_name)
    #新規ユーザの場合データベースに登録する。
    if user.save && room.save
      #登録に成功した場合、登録してマイページに移動する。
      session[:user] = user
      #中間テーブルに追加する
      room.users << user
      #認証情報をヘッダに付与してリダイレクトする。
      redirect_to url_for(action: 'mypage', only_path: false, user: user.user_name, password: user.password)
    else
      #失敗した場合、入力画面に戻る。
      redirect_to url_for action: 'new'
    end
  end

  #公開しない処理の定義
  private
  #POST時のPOST内容を表示する
  def user_info
    params.require(:user).permit(:user_name, :password)
  end
end
