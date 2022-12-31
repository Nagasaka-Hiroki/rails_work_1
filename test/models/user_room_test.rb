require "test_helper"

class UserRoomTest < ActiveSupport::TestCase
  #成功を期待するパターン
  test "create test" do
    user = User.find_by user_name: "nkun"
    room = Room.find_by room_name: "nkun"
    user_room = UserRoom.create! user: user, room: room
    assert_instance_of UserRoom, user_room, "インスタンスの作成に失敗しました。"
  end

  #失敗を期待するパターン レコードが空の場合
  test "empty test" do
    #空のレコードを許可しない。
    empty_record = UserRoom.new user: nil, room: nil
    assert_not empty_record.save, "正しく保存されました。空白は許可されていないはずです。"
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
      assert_not invalid_record.save, "正しく保存されました。バリデーションに誤りが有ります。"

      #!有りのメソッドの確認。
      assert_raises(ActiveRecord::RecordInvalid) do
        UserRoom.create! user: dummy_user, room: dummy_room
      end
    else
      flunk "invalid record: テストの設定がおかしいです。"
    end
  end
end
