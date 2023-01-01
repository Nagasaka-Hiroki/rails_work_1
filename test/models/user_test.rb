require "test_helper"

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  #成功を期待するパターン
  test "create test" do
    #新しい名前のユーザ、空でないユーザ名、半角英数字で空白を許可しない。
    #パスワードは空でない、半角英数字で空白を許可しない。
    user = User.create!(user_name: "SampleUser", password: "SamplePass")
    assert_instance_of User, user, "正しく作成されませんでした。バリデーションが間違っています。"
  end

  #失敗を期待するパターン1 既存のユーザを作成
  test "create exists user" do
    nkun = User.find_by(user_name: "nkun")
    user = User.new(user_name: nkun.user_name, password: "anotherpass")
    assert_not user.save, "保存に成功しました。間違っています。"
  end

  #失敗を期待するパターン2
  test "wrong user name" do
    #半角英数字以外の記号と空白を突っ込んだ情報
    assert_raises(ActiveRecord::RecordInvalid) do
      User.create!(user_name: "!#$%&'()=-~^ |?", password: "newpassword")
    end
    user = User.new(user_name: "!#$%&'()=-~^ |?", password: "newpassword")
    assert_not user.save, "作成されました。バリデーションが間違えています。"
  end
  test "wrong user password" do
    #半角英数字以外の記号と空白を突っ込んだ情報
    assert_raises(ActiveRecord::RecordInvalid) do
      User.create!(user_name: "newuser", password: "!#$%&'()=-~^ |?")
    end
    user = User.new(user_name: "newuser", password: "!#$%&'()=-~^ |?")
    assert_not user.save, "作成されました。バリデーションが間違えています。"
  end

  #失敗を期待するパターン3
  test "too long user name" do
    #16文字以上
    assert_raises(ActiveRecord::RecordInvalid) do
      User.create!(user_name: "123456789abcdefg", password: "123456789abcdefg")
    end
    user = User.new(user_name: "123456789abcdefg", password: "123456789abcdefg")
    assert_not user.save, "作成されました。バリデーションが間違えています。"
  end
  test "too long password" do
    #16文字以上
    assert_raises(ActiveRecord::RecordInvalid) do
      User.create!(user_name: "abc", password: "123456789abcdefg")
    end
    user = User.new(user_name: "abc", password: "123456789abcdefg")
    assert_not user.save, "作成されました。バリデーションが間違えています。"
  end

  #失敗を期待するパターン4
  test "create empty user_name" do
    #空を許さない。
    #ユーザ名が空
    assert_raises(ActiveRecord::RecordInvalid) do
      User.create!(user_name: "", password: "notempty")
    end
    user = User.new(user_name: "", password: "notempty")
    assert_not user.save, "空であるにも関わらず作成されました。バリデーションが間違っています。"
  end
  test "create empty password" do
    #パスワードが空
    assert_raises(ActiveRecord::RecordInvalid) do
      User.create!(user_name: "notempty", password: "")
    end
    user = User.new(user_name: "notempty", password: "")
    assert_not user.save, "空であるにも関わらず作成されました。バリデーションが間違っています。"
  end
end
