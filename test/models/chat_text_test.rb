require "test_helper"

class ChatTextTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  #インスタンスの生成を共通化する。
  def setup
    @chat_text = ChatText.create content: "<div>test text</div>"
    @user = User.find_by user_name: 'nkun'
    @room = Room.find_by room_name: 'nkun'
  end

  #定義したインスタンスの状態を確認する。インスタンスに対して代入がされているか確認。
  test "check instance variable" do
    assert @chat_text
    assert @user
    assert @room
  end

  #モデルで宣言したメソッドが正しいか調べる。
  test "check set chat table" do
    @chat = @chat_text.set_chat_table @user, @room
    p @chat
    assert @chat , "作成には成功するはずである。"
    #別の方法も試す。
    cookies_info = [@user, @room]
    @chat_alt = @chat_text.set_chat_table *cookies_info
    p @chat_alt
    assert @chat_alt , "作成には成功するはずである。"
  end
end
