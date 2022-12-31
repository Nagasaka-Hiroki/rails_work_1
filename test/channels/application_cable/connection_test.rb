require "test_helper"

class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase

  #成功時の共通部分を切り出し。
  def successful_connection_setup(&block)
    @user = User.find_by(user_name: "nkun")
    @room = Room.find_by(room_name: "nkun")
    cookies[:user_info] = @user.id
    cookies[:room_info] = @room.id
    #テスト前にコネクトを実行する。
    connect
    #テスト内容をブロックで受け取る。
    block&.call
    #最後は切断する
    disconnect
  end
  #失敗時の共通部分切り出し。
  def failed_connection_setup(&block)
    #フィクスチャファイルで指定していない値を使う。
    cookies[:user_info] = 100
    cookies[:room_info] = 100
    #テスト前にコネクトを実行する。
    connect
    #テスト内容をブロックで受け取る。
    block&.call
    #最後は切断する
    disconnect
  end

  #成功を期待するパターン
  test "successful connection" do
    successful_connection_setup do
      assert_equal @user, connection.current_user, "ログインしているユーザと異なります。"
      assert_equal @room, connection.current_room, "送信されたルームと異なります。"
    end
  end

  #失敗を期待するパターン
  test "failed connection" do
    assert_reject_connection do
      failed_connection_setup
    end
  end

end
