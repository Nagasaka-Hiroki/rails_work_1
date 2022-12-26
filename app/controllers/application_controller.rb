class ApplicationController < ActionController::Base
    #処理を定義する。
    private
    #認証に関する処理をまとめる。
    def basic_auth
      #基本認証
      authenticate_or_request_with_http_basic('Application') do |name, pw|  
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
