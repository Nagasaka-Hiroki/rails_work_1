class Room < ApplicationRecord
    #UserとRoomの多対多を実装する
    #中間テーブルは:user_roomsとして作成
    has_many :user_rooms
    has_many :users, through: :user_rooms
    #Chatモデルとのリレーションを定義する
    has_many :chats
    has_many :chat_texts, through: :chats

    #モデルの検証ルールを追加する。
    validates :room_name,  #ルーム名の検証ルール
    uniqueness: true,      #唯一である。
    presence:   true,      #空を許可しない。
    length: { in: 1..15 }, #1文字以上16文字未満。
    format: { with: %r{[a-zA-Z\d]*} } #半角英数字のみを許可する。空白は許可しない。
end
