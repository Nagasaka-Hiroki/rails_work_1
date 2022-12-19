class RoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "room_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  #クライアント側の挙動で呼び出される
  def speak(data)
    message = Message.create!(content: data["message"])
    ActionCable.server.broadcast(
      "room_channel", { message: render_message(message)}
    )
  end

  private
  def render_message(message)
    ApplicationController.render(
      partial: "messages/message",
      locals: {message: message }
    )
end
