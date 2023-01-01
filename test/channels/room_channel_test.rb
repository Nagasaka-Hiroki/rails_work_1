require "test_helper"

class RoomChannelTest < ActionCable::Channel::TestCase
  # test "subscribes" do
  #   subscribe
  #   assert subscription.confirmed?
  # end

  #描画部分を持ってくる。
  def draw_html
    chat = Chat.last
    ApplicationController.render(
      partial: "rooms/chat",
      locals: {chat: chat }
    )
  end

  #認証に成功する場合のサブスクリプション
  def success_subscription(&block)
    #ユーザとルームを指定する。
    user = User.find_by(user_name: 'nkun')
    room = Room.find_by(room_name: 'nkun')
    #コネクションに認証情報を付与する。
    stub_connection(current_user: user, current_room: room)
    #サブスクライブする前にstub_connectionを設定しないとエラーが出る。
    subscribe

    #処理を実行する
    block&.call

    #終了時は切断する。
    unsubscribe
  end

  #失敗するときのサブスクリプション
  def failed_subscription(&block)
    #ユーザとルームを指定する。
    user = nil
    room = nil
    #コネクションに認証情報を付与する。
    stub_connection(current_user: user, current_room: room)
    #サブスクライブする前にstub_connectionを設定しないとエラーが出る。
    subscribe

    #処理を実行する
    block&.call

    #終了時は切断する。
    unsubscribe
  end

  #成功を期待する場合
  test "normal behavior" do
    success_subscription do
      #購読されたか確認する。
      assert subscription.confirmed?
      #room_channelストリームが購読されているか確認する。
      assert_has_stream "room_channel"

      #データベースを使うアクションを実行する。
      #実行前は空のはず
      assert_not ChatText.exists?, "データベースにデータがあります。誤りです。"

      #データを作成しブロードキャストする。
      perform :speak,  {content: "<div>test message</div>"} 
      #部分テンプレートで描画した結果と同一か確認する。
      assert_broadcast_on("room_channel", { content: draw_html }) #この書き方もできるrails apiを参照

      #実行後はデータが存在するはず。
      assert ChatText.exists?, "データベースにデータがありません。誤りです。"
    end
  end

  #失敗を期待する場合
  test "failed behavior" do
    failed_subscription do
      #購読されたか確認する。
      assert subscription.confirmed?
      #room_channelストリームが購読されているか確認する。
      assert_has_stream "room_channel"
      
      #データベースを使うアクションを実行する。認証情報がないので失敗するはずである。
      #実行前は空のはず
      assert_not ChatText.exists?, "データベースにデータがあります。誤りです。"

      #認証情報がないので例外が発生するはずである。
      assert_raises(ActiveRecord::RecordInvalid) do
        #データを作成しブロードキャストする。
        perform :speak,  {content: "<div>test message</div>"} 
      end
      
      #実行後もデータが存在しないはずである。データが存在すると不明な発言者のデータが残る。
      assert_not ChatText.exists?, "データベースにデータがあります。誤りです。"
    end
  end

end
