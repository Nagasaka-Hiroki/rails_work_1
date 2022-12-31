class RoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "room_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  #クライアント側の挙動で呼び出される
  def speak(data)
    #ユーザ及びルームが不明の場合はテキストも保存できない。
    ActiveRecord::Base.transaction do
      chat_text = ChatText.create!(content: data["content"])     #エラー時は例外が発生する。
      @chat = chat_text.set_chat_table current_user, current_room #エラー時は例外が発生する。
    end
    #問題がなければブロードキャストする。
    ActionCable.server.broadcast(
      "room_channel", { content: render_chat(@chat)}
    )
  end

  private
  #描画処理を分ける。
  def render_chat(chat)
    ApplicationController.render(
      partial: "rooms/chat",
      locals: {chat: chat }
    )
  end
end
