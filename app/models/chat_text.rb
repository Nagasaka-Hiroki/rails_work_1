#HTML Parserを使う。

class ChatText < ApplicationRecord
    #チャットの内容と紐付ける
    has_rich_text :content
    #Chatモデルと紐付け。呼び出されるのがこちらなのでこちらを従とする。
    has_one :chat
    #チャットテキスト自体もユーザ名とルーム名と紐付ける必要があるので定義
    has_one :user, through: :chat
    has_one :room, through: :chat
    
    #標準のバリデーションのルールを追加する。
    validates   :content,    #コンテンツの検証ルール
        presence:   true     #空を許可しない。
    
    #新しいバリデーションルールを追加する
    validate :text_exists!, on: %i[ create! save! update! ]
    validate :text_exists , on: %i[ create  save  update  ]
    
    #中間テーブルに追加をして参照できるようにする。
    def set_chat_table user=nil, room=nil
        Chat.create user: user, room: room, chat_text: self
    end

    private
    #!付きメソッドでのバリデーション
    def text_exists!
        #共通部分を呼び出し、例外処理を追加する。
        filter_html do
            #エラーを追加する。
            errors.add(:content, "Only spaces or new lines cannot be saved.")
            #マッチしなければ例外を発生させる。
            raise ActiveRecord::RecordInvalid
        end
    end

    #!なしメソッドでのバリデーション
    def text_exists
        #共通部分を呼び出し、例外処理を追加する。
        filter_html do
            #エラーを追加する。
            errors.add(:content, "Only spaces or new lines cannot be saved.")
        end
    end
    
    #バリデーションで共通する解析部分を取り出す。
    def filter_html(&error_proc)
        #受信したデータを解析する。
        parsed_html = Nokogiri::HTML::DocumentFragment.parse(self.content.body.to_s)
        #空白と改行以外のテキストを含むか？
        #この処理で改行タグ<br>は消える。
        innerhtml_text = parsed_html.text
        filter = %r{[\S]+} #空白文字列以外が存在すれば入力があったと判定する。
        #マッチしなければ例外を発生させる。
        unless filter.match?(innerhtml_text)
            #処理の異なる部分は別に切り出す。
            error_proc.call
        end
    end
end
