class CreateChatTexts < ActiveRecord::Migration[7.0]
  def change
    create_table :chat_texts do |t|

      t.timestamps
    end
  end
end
