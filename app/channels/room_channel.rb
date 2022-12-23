class RoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "room_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  #クライアント側の挙動で呼び出される
  def speak(data)
    chat_text = ChatText.create!(data["content"])
    chat = chat_text.set_chat_table
    ActionCable.server.broadcast(
      "room_channel", { content: render_chat(chat)}
    )
  end

  private
  def render_chat(chat)
    ApplicationController.render(
      partial: "rooms/chat",
      locals: {chat: chat }
    )
  end
end
