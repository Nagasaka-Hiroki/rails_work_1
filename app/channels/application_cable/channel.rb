#記述については、すべてのチャネルに共通する処理を書くイメージ（親チャネル) 。以下が参考になる。
#https://railsguides.jp/action_cable_overview.html

module ApplicationCable
  class Channel < ActionCable::Channel::Base
  end
end
