require "test_helper"

class RoomChannelTest < ActionCable::Channel::TestCase
  # test "subscribes" do
  #   subscribe
  #   assert subscription.confirmed?
  # end

  def setup
    #購読を開始する。現状特別な設定をしていないので引数なしで購読できるはず。
    subscribe
    @user = User.find_by(user_name: 'nkun')
    @room = Room.find_by(room_name: 'nkun')
  end
  #action cableの挙動をテスト。
  #購読をテストする。
  test "subscrible test" do
    #購読されたか確認する。
    assert subscription.confirmed?
    #room_channelストリームが購読されているか確認する。
    assert_has_stream "room_channel"
  end
  
  #識別情報の仕様についてテスト。
  #下記が上手く動かない。stub_connectionは
  #Connection < ActionCable::Connection::Baseのidentified_byで
  #示された認証情報をテスト時にセットするものではないのか？
  #test "find room test" do
  #  stub_connection(current_user: @user, current_room: @room)
  #  perform :speak, { content: "<div>test message</div>" }
  #end
end
