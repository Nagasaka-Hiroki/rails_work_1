class UserRoom < ApplicationRecord
  #中間テーブルのアソシエーション
  belongs_to :user
  belongs_to :room

  #新しいバリデーションルールを追加。
  #保存する関連先が存在するか確認
  validate :record_exists_check , on: %i[ create  save  update  ]
  validate :record_exists_check!, on: %i[ create! save! update! ]
  #保存する組み合わせが唯一であるか確認
  validate :record_uniqueness_check , on: %i[ create  save  update  ]
  validate :record_uniqueness_check!, on: %i[ create! save! update! ]

  private
  #登録先のレコードが存在するか？
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

  #中間テーブルのユーザとルームの組み合わせがすでに存在するか検証する
  #!付きのメソッド。
  def record_uniqueness_check!
    the_record_already_exists? do
      raise ActiveRecord::RecordInvalid
    end
  end
  #!なしのメソッド
  def record_uniqueness_check
    the_record_already_exists?
  end

  #ユーザとルームの組み合わせが唯一であるか確認する。
  def the_record_already_exists?(&block)
    #UserRoomテーブルからまずユーザを検索する。結果は配列として受け取る。
    list_of_rooms = UserRoom.where(user: self.user)
    #配列の内容それぞれで新しく登録しようとするルームが存在するか調べる。
    list_of_rooms.each do |user_room|
      #trueのときすでに登録済みの組み合わせである
      #一つでも重複すればブロックの処理を実行する。何も実行しない場合のためにnextで抜ける。
      if user_room.room.eql?(self.room)
        errors.add(:id, "The record combination already exists.")
        block&.call
        next
      end
    end
  end

end
