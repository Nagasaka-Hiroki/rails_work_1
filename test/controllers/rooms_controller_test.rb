require "test_helper"

class RoomsControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  
  #インスタンス変数を作る。データベースから直接探す。
  def setup
    @user = User.find_by(user_name: 'nkun')
    @room = Room.find_by(room_name: 'nkun')
    @auths_header = { Authorization: ActionController::HttpAuthentication::Basic.encode_credentials(@user.user_name,@user.password)}
  end

  #ルーム一覧を表示できるか？
  test "show room list" do
    #認証なしでは入れないはず。
    get rooms_url
    assert_response :unauthorized

    #認証情報を付与してアクセス。
    get rooms_url, headers: @auths_header
    assert_response :success
  end

  #ルームインスタンスにアクセスできるか？
  test "get room instance" do
    #まず認証情報を記述してコントローラを起動しアクセスする。
    get url_for(@room) , headers: @auths_header
    #成功を期待する。
    assert_response :success
  end

  #クッキーでuser と roomを特定できるか？
  #別のユーザ情報と比較して失敗を検証する。
  test "check cookies" do
    get url_for(@room) , headers: @auths_header
    assert_response :success

    #コントローラ起動時にクッキーにユーザ情報が入っているはず。それを確かめる。
    assert_equal cookies[:user_info].to_i, @user.id, "ユーザ情報が異なる。"
    assert_equal cookies[:room_info].to_i, @room.id, "ルーム情報が異なる。"

    #データベース上の別のユーザidと比較する。失敗するはず。
    user_x = User.find_by(user_name: "xsan")
    room_x = Room.find_by(room_name: "xsan")

    assert_not_equal cookies[:user_info].to_i, user_x.id, "ユーザ情報が同一である。"
    assert_not_equal cookies[:room_info].to_i, room_x.id, "ルーム情報が同一である。"
  end
end
