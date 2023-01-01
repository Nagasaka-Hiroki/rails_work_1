require "test_helper"

class UserRoomTest < ActiveSupport::TestCase
  #成功を期待するパターン
  test "find user room" do
    #中間テーブルに登録したユーザとルームが存在するか？
    user_room = UserRoom.first
    assert_not_nil user_room.user, "ユーザが存在しません"
    assert_not_nil user_room.room, "ルームが存在しません"
  end
  test "create new record" do
    #新しいユーザとルームは作成を許可する。
    user = User.create!(user_name: "newuser", password: "newpassword")
    room = Room.create!(room_name: "newuser")
    user_room = UserRoom.new user: user, room: room
    assert user_room.save, "保存に失敗しました。"
    assert_not_nil user_room.user, "関連するユーザが存在しません。"
    assert_not_nil user_room.room, "関連するルームが存在しません。"
  end
  
  #失敗を期待する　すでに存在する組み合わせ
  test "create exists record combination" do
    user = User.find_by user_name: "nkun"
    room = Room.find_by room_name: "nkun"
    assert_raises(ActiveRecord::RecordInvalid) do
      user_room = UserRoom.create! user: user, room: room
    end
    user_room = UserRoom.new user: user, room: room
    assert_not user_room.save, "保存されました。バリデーションが間違っています。"
  end

  #失敗を期待するパターン レコードが空の場合
  test "empty record" do
    #空のレコードを許可しない。
    empty_record = UserRoom.new
    assert_not empty_record.save, "保存されました。空白は許可されていないはずです。"
  end

  #失敗を期待するパターン　存在しないレコードの場合。
  test "invalid record" do
    #存在しないレコードを許可しない
    dummy_user = User.new user_name: "dummy", password: "dummypass"
    dummy_room = Room.new room_name: "dummy"
    #存在しないことを確認。
    user_state = User.where(user_name: dummy_user.user_name).exists?
    room_state = Room.where(room_name: dummy_room.room_name).exists?
    unless user_state && room_state #両方存在しない場合を検証
      #!なしメソッドの確認。
      invalid_record = UserRoom.new user: dummy_user, room: dummy_room
      assert_not invalid_record.save, "保存されました。バリデーションに誤りが有ります。"

      #!有りのメソッドの確認。
      assert_raises(ActiveRecord::RecordInvalid) do
        UserRoom.create! user: dummy_user, room: dummy_room
      end
    else
      flunk "invalid record: テストの設定がおかしいです。"
    end
  end
end
