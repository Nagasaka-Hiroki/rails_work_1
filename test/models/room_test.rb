require "test_helper"

class RoomTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  #成功を期待するパターン
  test "create test" do
    #新しい名前のルーム、空でないルーム名、半角英数字で空白を許可しない。
    room = Room.create!(room_name: "SampleRoom")
    assert_instance_of Room, room, "正しく作成されませんでした。バリデーションが間違っています。"
  end
  #失敗を期待するパターン
  test "create exists room" do
    room_exists = Room.find_by(room_name: "nkun")
    assert_raises(ActiveRecord::RecordInvalid) do
      Room.create!(room_name: room_exists.room_name)
    end
    room = Room.new(room_name: room_exists.room_name)
    assert_not room.save, "作成されました。バリデーションが間違えています。"
  end

  test "wrong room name" do
    #半角英数字以外の記号と空白を突っ込んだ情報
    assert_raises(ActiveRecord::RecordInvalid) do
      Room.create!(room_name: "!#$%&'()=-~^ |?")
    end
    room = Room.new(room_name: "!#$%&'()=-~^ |?")
    assert_not room.save, "作成されました。バリデーションが間違えています。"
  end

  test "empty room name" do
    #空を許可しない
    assert_raises(ActiveRecord::RecordInvalid) do
      Room.create!(room_name: "")
    end
    room = Room.new(room_name: "")
    assert_not room.save, "作成されました。バリデーションが間違えています。"
  end

  test "too long room name" do
    #16文字以上
    assert_raises(ActiveRecord::RecordInvalid) do
      Room.create!(room_name: "123456789abcdefg")
    end
    room = Room.new(room_name: "123456789abcdefg")
    assert_not room.save, "作成されました。バリデーションが間違えています。"
  end
  
end
