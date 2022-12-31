class UserRoom < ApplicationRecord
  #中間テーブルのアソシエーション
  belongs_to :user
  belongs_to :room

  #新しいバリデーションルールを追加。
  validate :record_exists_check , on: %i[ create  save  update  ]
  validate :record_exists_check!, on: %i[ create! save! update! ]

  private
  #!なしのメソッドのバリデーション
  def record_exists_check
    find_user_room do
      #エラー情報を付与。
      errors.add(:id, "invalid user or room detected.")
    end
  end
  #!付きのメソッドのバリデーション
  def record_exists_check!
    find_user_room do
      #エラー情報を付与。
      errors.add(:id, "invalid user or room detected.")
      #マッチしなければ例外を発生させる。
      raise ActiveRecord::RecordInvalid
    end
  end

  #データベースに存在するか調べる。
  def find_user_room(&error_proc)
    #Userモデルのインスタンスをデータベースから探す。
    #なければnewしてインスタンスを生成する。
    user = User.find_or_initialize_by(user_name: self.user&.user_name)
    #Roomモデルも同様に実行する。
    room = Room.find_or_initialize_by(room_name: self.room&.room_name)
    #データが存在するか調べる。
    user_status = User.where(user_name: user.user_name).exists?
    room_status = Room.where(room_name: room.room_name).exists?
    unless user_status && room_status #片方でも存在しなければエラー
      error_proc.call
    end
  end
end
