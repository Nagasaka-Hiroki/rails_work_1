class CreateChats < ActiveRecord::Migration[7.0]
  def change
    create_table :chats do |t|
      t.references :chat_text, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :room, null: false, foreign_key: true

      t.timestamps
    end
  end
end
