class RoomsController < ApplicationController
    #すべての処理にログイン処理を付与する。
    before_action :basic_auth
    #変数のセット
    before_action :set_room, only: %i[ show  record_chat ]
    before_action :set_user, only: %i[ index show record_chat ]
    #一覧を表示する。
    def index
        #セッションからユーザを取り出す
        #@user = session[:user]
        #ユーザから、ユーザが見られるルーム一覧を取り出す
        @rooms = @user.rooms
    end
    #履歴を表示する
    def show
        #フォームのための変数
        @chat_text = ChatText.new
        #ルームの発言一覧を取り出す。
        #@user = session[:user]
        #set_room
        @chats = Chat.where(user: @user, room: @room)
    end
    #新しくルームを作るための画面を作る。
    def new
    end
    #新しくルームを作る処理を実装する。
    def create
    end
    #発言内容を保存する処理を書く
    def record_chat
        #発言内容を元に変数を作成
        #ChatTextはただのテキスト情報
        @chat_text = ChatText.new(content_params)
        #保存を検証
        @chat_text.save

        #中間テーブルに追加する。
        #user_idとroom_idを特定し、中間テーブルに追加する
        @chat = Chat.new user: @user, room: @room, chat_text: @chat_text
        #中間テーブルを保存する
        @chat.save
        #@room.chats << @chat
        #処理が終われば元のページに戻る。
        redirect_to action: :show
    end

    #
    private
    def set_room
        #URLの末尾からルームを特定する
        @room = Room.find(params[:id])
    end
    def set_user
        #セッションからユーザを取り出す。
        @user = session[:user]
    end
    #リッチテキストの内容を取得する。
    def content_params
        params.require(:chat_text).permit(:content)
    end
end
