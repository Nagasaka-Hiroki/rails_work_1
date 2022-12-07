require "test_helper"
require "debug"

class AuthsControllerTest < ActionDispatch::IntegrationTest
  #修正済みの自動生成テスト
  test "should get login" do
    get login_auths_url
    assert_response :success
  end
  #修正済みの自動生成テスト
  test "should get logout" do
    get logout_auths_url
    assert_response :success
  end
  
  #paramsの検証（フォームの送信内容)
  test "params method check" do
    #binding.break
    #@user = User.new
    #post auths_url , params: {user: {user_name: 'nkun', password: 'password'}} #, headers: { Authorization: ActionController::HttpAuthentication::Basic.encode_credentials("nkun","password")}
    post auths_url , params: {user: {user_name: 'test_user', password: 'test_password'}} #, headers: { Authorization: ActionController::HttpAuthentication::Basic.encode_credentials("nkun","password")}
    assert_response :success
  end

  #認証
  test "keep session check" do
    #ログインする
    get login_auths_url , headers: { Authorization: ActionController::HttpAuthentication::Basic.encode_credentials("nkun","password")}
    assert_response :redirect
    #リダイレクトに成功したらその先を確認する。
    get mypage_auths_url #, headers: { Authorization: ActionController::HttpAuthentication::Basic.encode_credentials("nkun","password")}
    assert_response :success
    #ログアウトしてセッション情報を確認する
    get logout_auths_url
    assert_response :redirect
    #ログアウトした先を表示する。
    get auths_url
    assert_response :success
  end

  #認証に失敗させる
  test "failed authorization" do
    #間違えたパスワードを入力する。
    get login_auths_url , headers: { Authorization: ActionController::HttpAuthentication::Basic.encode_credentials("nkun_janaiyo","matigatteruyo")}
    #失敗を期待する
    assert_response :unauthorized
  end
end
