class ApplicationController < ActionController::Base
    #処理を定義する。
    private
    #認証に関する処理をまとめる。
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
    
    #セッションの設定
    def set_session hash_list={}
      hash_list&.each do |key,value|
        session[key]=value
      end
    end
  
    def empty_auth
      #ユーザ名とパスワードに偽情報をいれてわざと認証を成功させて上書きする。
      authenticate_or_request_with_http_basic('Application') do |name, pw|
        if name=="WT5CZXGqkwLuv05D" && pw=="WT5CZXGqkwLuv05D"
          session[:user] = nil
          next true
        else
          next false
        end
      end
    end
    #アプリケーション全体に共通の例外処理をまとめる。
end
