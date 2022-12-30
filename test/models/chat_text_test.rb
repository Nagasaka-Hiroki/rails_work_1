require "test_helper"

class ChatTextTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  #インスタンスの生成を共通化する。
  def setup
    @chat_text = ChatText.create! content: "<div>test text</div>"
    @user = User.find_by user_name: 'nkun'
    @room = Room.find_by room_name: 'nkun'
  end

  #定義したインスタンスの状態を確認する。インスタンスに対して代入がされているか確認。
  test "check instance variable" do
    assert_instance_of ChatText, @chat_text
    assert_instance_of User,     @user
    assert_instance_of Room,     @room
  end

  #モデルで宣言したメソッドが正しいか調べる。
  test "check set chat table" do
    chat = @chat_text.set_chat_table @user, @room
    assert_instance_of Chat, chat , "作成には成功するはずである。"
    #別の方法も試す。
    cookies_info = [@user, @room]
    chat_alt = @chat_text.set_chat_table *cookies_info
    assert_instance_of Chat, chat_alt , "作成には成功するはずである。"
  end

  #作成に失敗するパターン１　空の場合
  test "empty test" do
    assert_raises(ActiveRecord::RecordInvalid) do
      ChatText.create! content: ""
    end
    empty_chat_text = ChatText.new content: ""
    assert_not empty_chat_text.save, "正しく作成されました。バリデーションが間違っています。"
  end
  #作成に失敗するパターン２　タグに囲まれた、空白と改行（&nbsp;と<br>と\n)
  test "space text test" do
    #禁止のパターンを複数列挙する。
    invalid_inputs = [ "<div> \n</div>","<div> </div>","<div> &nbsp; </div>","<div> <br> </div>"  ]

    invalid_inputs.each do |value|
      assert_raises(ActiveRecord::RecordInvalid) do
        ChatText.create! content: value
      end
      space_text = ChatText.new content: value
      assert_not space_text.save, "正しく作成されました。バリデーションが間違っています。"
    end
  end
end
