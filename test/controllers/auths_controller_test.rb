require "test_helper"
require "debug"

class AuthsControllerTest < ActionDispatch::IntegrationTest
  #認証を失敗させる
  test "failed authorization" do
    #間違えたユーザ名とパスワードを入力する。
    get mypage_auths_url , headers: { Authorization: ActionController::HttpAuthentication::Basic.encode_credentials("nkun_janaiyo","matigatteruyo")}
    #失敗を期待する
    assert_response :unauthorized
  end
  #認証を成功させる
  test "success authorization" do
    #正しい情報を入力する
    get mypage_auths_url , headers: { Authorization: ActionController::HttpAuthentication::Basic.encode_credentials("nkun","password")}
    #成功を期待する
    assert_response :success
  end
  #ログアウトする
  test "logout procedure" do
    #正しい情報を入力する
    get mypage_auths_url , headers: { Authorization: ActionController::HttpAuthentication::Basic.encode_credentials("nkun","password")}
    #成功を期待する
    assert_response :success

    #ログアウトを実行する
    patch logout_auths_url
    assert_response :unauthorized
  end
end
