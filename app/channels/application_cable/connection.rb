#記述については、以下が参考になる。
#https://railsguides.jp/action_cable_overview.html#%E3%82%B3%E3%83%8D%E3%82%AF%E3%82%B7%E3%83%A7%E3%83%B3%E3%81%AE%E8%A8%AD%E5%AE%9A
#上記にはクッキーに保存された認証済みユーザ情報の参照について書かれている。

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    #action cableで認証情報を追加できる。
    identified_by :current_user, :current_room

    #コネクションのインスタンス生成後に実行されるメソッド（connectは特別な名前）
    def connect
      #コネクション開始時にクッキーから認証情報を取り出す。
      self.current_user = find_current_user
      self.current_room = find_current_room
    end
    #コネクションの切断時に実装されるメソッド。
    #def disconnect
    #end

    private
    #ユーザを探す。
    def find_current_user
      if current_user = User.find(cookies[:user_info])
        current_user
      else
        #見つからない場合は404のエラーで返す。
        reject_unauthorized_connection
      end
    end
    #ルームを探す
    def find_current_room
      if current_room = Room.find(cookies[:room_info])
        current_room
      else
        #見つからない場合は404のエラーで返す。
        reject_unauthorized_connection
      end
    end
  end
end
