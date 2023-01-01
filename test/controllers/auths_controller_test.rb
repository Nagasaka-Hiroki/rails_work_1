require "test_helper"

class AuthsControllerTest < ActionDispatch::IntegrationTest
  #認証情報をセットしたヘッダを設定する。
  def set_auths_header(name,pw)
    auths_header = ActionController::HttpAuthentication::Basic.encode_credentials(name,pw)
    { Authorization: auths_header}
  end

  #ルートにアクセス auths#show
  test "get root url" do
    #アクセスに成功するか確認。
    get root_url
    assert_response :success
  end

  #ログアウトする auths#logout
  test "logout procedure" do
    #正しい情報を入力する
    get mypage_auths_url , headers: set_auths_header("nkun","password")
    #成功を期待する
    assert_response :success
    #ログアウトを実行する。ログアウトサイトに移動する。
    get logout_auths_url , headers: set_auths_header('WT5CZXGqkwLuv05D','WT5CZXGqkwLuv05D')
    assert_response :success
    #ログアウト用のユーザ情報がなければログアウトできない。
    get logout_auths_url 
    assert_response :unauthorized
  end

  #マイページにアクセスする。auths#mypage
  #認証を失敗させる
  test "failed authorization" do
    #間違えたユーザ名とパスワードを入力する。
    get mypage_auths_url , headers: set_auths_header("nkun_janaiyo","matigatteruyo")
    #失敗を期待する
    assert_response :unauthorized
  end
  #認証を成功させる
  test "success authorization" do
    #正しい情報を入力する
    get mypage_auths_url , headers: set_auths_header("nkun","password")
    #成功を期待する
    assert_response :success
  end

  #ユーザ登録画面にアクセスする。auths#new
  test "get new auths url" do
    get new_auths_url
    assert_response :success
  end

  #選択画面を表示 auths#show
  test "get show auths url" do
    get auths_url
    assert_response :success
  end

  #新しくユーザを登録する。 auths#create
  #成功する場合
  test "success post auths url" do
    #ユーザが増えたか確認
    assert_difference("User.count",1,"ユーザが増えていません。") do
      post auths_url, params: { user: { user_name: "newuser1", password: "newpassword1"}}
      assert_response :redirect
      new_user_page = url_for(action: 'mypage', only_path: false, user: "newuser1", password: "newpassword1")
      assert_redirected_to new_user_page, "リダイレクト先が違います。"
    end
    #ルームが増えたか確認
    assert_difference("Room.count",1,"ルームが増えていません。") do
      post auths_url, params: { user: { user_name: "newuser2", password: "newpassword2"}}
      assert_response :redirect
      new_user_page = url_for(action: 'mypage', only_path: false, user: "newuser2", password: "newpassword2")
      assert_redirected_to new_user_page, "リダイレクト先が違います。"
    end
    #中間テーブルが増えたか確認。
    #ルームが増えたか確認
    assert_difference("UserRoom.count",1,"中間テーブルUserRoomが増えていません。") do
      post auths_url, params: { user: { user_name: "newuser3", password: "newpassword3"}}
      assert_response :redirect
      new_user_page = url_for(action: 'mypage', only_path: false, user: "newuser3", password: "newpassword3")
      assert_redirected_to new_user_page, "リダイレクト先が違います。"
    end
  end
  #失敗する場合空白を入力
  test "failed post auths url" do
    assert_no_difference("User.count+Room.count+UserRoom.count","データベースにレコードが追加されています。") do
      post auths_url, params: { user: { user_name: " ", password: " "}}
      assert_response :redirect
      assert_redirected_to new_auths_url, "リダイレクト先が違います。"
    end
  end

  #ルーティングエラー
  test "rooting error" do
    #間違えたURLにアクセスする。
    wrong_url = root_url+"wrong_path"
    assert_raise(ActionController::RoutingError) do
      get wrong_url
    end
  end
end
