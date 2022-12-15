class ChatText < ApplicationRecord
    #チャットの内容と紐付ける
    has_rich_text :content
    #Chatモデルと紐付け。呼び出されるのがこちらなのでこちらを従とする。
    has_one :chat
end
