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
    post auths_url , params: {user: {user_name: 'nkun', password: 'password'}} #, headers: { Authorization: ActionController::HttpAuthentication::Basic.encode_credentials("nkun","password")}
    assert_response :success
  end
end
