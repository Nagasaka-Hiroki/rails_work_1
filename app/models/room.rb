class Room < ApplicationRecord
    #UserとRoomの多対多を実装する
    #中間テーブルは:user_roomsとして作成
    has_many :user_rooms
    has_many :users, through: :user_rooms
    #Chatモデルとのリレーションを定義する
    has_many :chats
    has_many :chat_texts, through: :chats
end
