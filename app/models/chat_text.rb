class ChatText < ApplicationRecord
    #チャットの内容と紐付ける
    has_rich_text :content
    #Chatモデルと紐付け。呼び出されるのがこちらなのでこちらを従とする。
    has_one :chat
    #チャットテキスト自体もユーザ名とルーム名と紐付ける必要があるので定義
    has_one :user, through: :chat
    has_one :room, through: :chat
end
