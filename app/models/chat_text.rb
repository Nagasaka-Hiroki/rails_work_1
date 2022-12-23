class ChatText < ApplicationRecord
    #チャットの内容と紐付ける
    has_rich_text :content
    #Chatモデルと紐付け。呼び出されるのがこちらなのでこちらを従とする。
    has_one :chat
    #チャットテキスト自体もユーザ名とルーム名と紐付ける必要があるので定義
    has_one :user, through: :chat
    has_one :room, through: :chat

    #コールバックを記述する。
    #after_create :set_chat_table, on: RoomChannel.speak
    #コールバックで実装しようとしたが、返り値を使用したいと思ったのでやめる。
    
    #中間テーブルに追加をして参照できるようにする。
    def set_chat_table
        user = session[:user]
        room = Room.find(params[:id])
        chat = Chat.create(user: user, room: room, chat_text: self)
    end
end
