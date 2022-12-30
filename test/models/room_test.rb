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
  #失敗を期待するパターン1
  test "fail create test" do
    #半角英数字以外の記号と空白を突っ込んだ情報かつ16文字以上
    assert_raises(ActiveRecord::RecordInvalid) do
      Room.create!(room_name: "!\"#$%&'()=-~^ |\\{}*;+_?/><")
    end
    room = Room.new(room_name: "!\"#$%&'()=-~^ |\\{}*;+_?/><")
    assert_not room.save, "正しく作成されました。バリデーションが間違えています。"
  end
end
