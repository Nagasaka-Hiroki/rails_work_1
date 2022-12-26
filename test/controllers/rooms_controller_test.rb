require "test_helper"

class RoomsControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  
  #インスタンス変数を作る。データベースから直接探す。
  def setup
    @user = User.find_by(user_name: 'nkun')
    @room = Room.find_by(room_name: 'nkun')
  end
  #クッキーでuser と roomを特定できるか？
  test "identify user and room" do
    #まず認証情報を記述してコントローラを起動しアクセスする。
    p url_for(@room)
    get url_for(@room) , headers: { Authorization: ActionController::HttpAuthentication::Basic.encode_credentials("nkun","password")}
    #成功を期待する。
    assert_response :success
    #コントローラ起動時にクッキーにユーザ情報が入っているはず。それを確かめる。
    assert_equal cookies[:user_info].to_i, @user.id, "ユーザ情報が異なる。"
    assert_equal cookies[:room_info].to_i, @room.id, "ルーム情報が異なる。"
    p "クッキー上のユーザ情報: cookies[:user_info]=#{cookies[:user_info]}"
    p "クッキー上のユーザ情報: cookies[:room_info]=#{cookies[:room_info]}"
    p "クッキー上のユーザ情報: user_name=#{User.find(cookies[:user_info]).user_name}"
    p "クッキー上のユーザ情報: room_name=#{Room.find(cookies[:room_info]).room_name}"
  end
end
