require "test_helper"

class ChatTest < ActiveSupport::TestCase
  def setup
    @user = User.find_by user_name: "nkun"
    @room = Room.find_by room_name: "nkun"
    @chat_text = ChatText.create! content: "<div>test text</div>"
  end
  #成功を期待するパターン
  test "create test" do
    chat = Chat.create! user: @user, room: @room, chat_text: @chat_text
    assert_instance_of Chat, chat, "インスタンスの作成に失敗しました。"
    assert_not_nil chat.user, "ユーザが存在しません"
    assert_not_nil chat.room, "ルームが存在しません"
    assert_not_nil chat.chat_text, "入力が存在しません"
  end

  #失敗を期待するパターン
  #空を許可しない。
  test "empty record" do
    #インスタンスを作成し失敗するか検証する。
    #!なしのメソッド。
    chat = Chat.new
    assert_not chat.save, "作成されました。空は許可されていません。"

    #!有りのメソッド。
    assert_raises(ActiveRecord::RecordInvalid) do
      Chat.create!
    end
  end
  #データベースに存在しないレコードはエラーになる。
  test "invalid record" do
    #データベースに存在しないインスタンスを作成する。
    user = User.find_or_initialize_by(user_name: "dummy")
    room = Room.find_or_initialize_by(room_name: "dummy")
    chat_text = ChatText.new content: "<div>test text</div>"
    #存在しないことを確認する。
    user_status = User.where(user_name: user.user_name).exists?
    room_status = Room.where(room_name: room.room_name).exists?
    chat_text_status = ChatText.where(id: chat_text.id).exists?
    #一つでも存在すれば失敗させる。
    flunk "テストの設定が間違っています。" if user_status || room_status || chat_text_status

    #インスタンスを作成し失敗するか検証する。
    #!なしのメソッド。
    chat = Chat.new user: user, room: room, chat_text: chat_text
    assert_not chat.save, "作成されました。無効な入力のはずです。"

    #!有りのメソッド。
    assert_raises(ActiveRecord::RecordInvalid) do
      Chat.create! user: user, room: room, chat_text: chat_text
    end
  end
end
