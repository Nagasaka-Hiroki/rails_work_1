class Chat < ApplicationRecord
  #ユーザとルームのidと紐付け
  belongs_to :user
  belongs_to :room
  #コンテンツを紐付け、１対１の関係
  belongs_to :chat_text

  #新しいバリデーションルールを追加。
  validate :record_exists_check , on: %i[ create  save  update  ]
  validate :record_exists_check!, on: %i[ create! save! update! ]

  private
  #!なしのメソッドのバリデーション
  def record_exists_check
    find_record_attr
  end
  #!付きのメソッドのバリデーション
  def record_exists_check!
    find_record_attr do
      #マッチしなければ例外を発生させる。
      raise ActiveRecord::RecordInvalid
    end
  end

  #データベースに存在するか調べる。
  def find_record_attr(&block)
    #Userモデルのインスタンスをデータベースから探す。
    #なければnewしてインスタンスを生成する。
    user = User.find_or_initialize_by(user_name: self.user&.user_name)
    #Roomモデルも同様に実行する。
    room = Room.find_or_initialize_by(room_name: self.room&.room_name)
    #ChatTextモデルも同様に実行する。
    chat_text = ChatText.find_or_initialize_by(id: self.chat_text&.id)
    #データが存在するか調べる。
    user_status = User.where(user_name: user.user_name).exists?
    room_status = Room.where(room_name: room.room_name).exists?
    chat_text_status = ChatText.where(id: chat_text.id).exists?
    unless user_status && room_status && chat_text_status #1つでも存在しなければエラー
      #エラー情報を付与。
      errors.add(:id, "invalid user, room or chat_text detected.")
      block&.call
    end
  end
end
