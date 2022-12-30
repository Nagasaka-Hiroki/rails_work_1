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
  #失敗を期待するパターン1
  test "fail create test" do
    #半角英数字以外の記号と空白を突っ込んだ情報かつ16文字以上
    assert_raises(ActiveRecord::RecordInvalid) do
      User.create!(user_name: "!\"#$%&'()=-~^ |\\{}*;+_?/><", password: "!\"#$%&'()=-~^ |\\{}*;+_?/><")
    end
    user = User.new(user_name: "!\"#$%&'()=-~^ |\\{}*;+_?/><", password: "!\"#$%&'()=-~^ |\\{}*;+_?/><")
    assert_not user.save, "正しく作成されました。バリデーションが間違えています。"
  end
  #失敗を期待するパターン2 1が失敗しないので追加で検証
  test "fail create test2" do
    #空白を許さない。
    assert_raises(ActiveRecord::RecordInvalid) do
      User.create!(user_name: " ", password: " ")
    end
    user = User.new(user_name: " ", password: " ")
    assert_not user.save, "空白であるにも関わらず正しく作成されました。バリデーションが間違っています。"
  end
end
