class RoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "room_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  #クライアント側の挙動で呼び出される
  def speak(data)
    chat_text = ChatText.create(content: data["content"])
    chat = chat_text.set_chat_table current_user, current_room
    ActionCable.server.broadcast(
      "room_channel", { content: render_chat(chat)}
      #受信内容をそのまま返す場合以下
      #"room_channel", { content: data["content"]}
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
