class Chat < ApplicationRecord
  #ユーザとルームのidと紐付け
  belongs_to :user
  belongs_to :room
  #コンテンツを紐付け、１対１の関係
  #chatからchattextを呼び出すため、chatを主とする。
  belongs_to :chat_text
  #chatの一覧を取得する、これはよく使うと思うのでスコープで定義する。
end
