class RoomsController < ApplicationController
    #すべての処理にログイン処理を付与する。
    before_action :basic_auth
    #変数のセット
    before_action :set_room, only: %i[ show ]
    before_action :set_user, only: %i[ index show ]
    #レイアウトをセット
    layout 'room_layout', only: %i[ index show ]
    #一覧を表示する。
    def index
        #ユーザから、ユーザが見られるルーム一覧を取り出す
        @rooms = @user.rooms
    end
    #履歴を表示する
    def show
        #ルームの発言一覧を取り出す。
        @chats = Chat.where(room: @room)
        #action cableの認証で使うための情報をクッキーに保存する。
        cookies[:user_info] = {value: @user.id}
        cookies[:room_info] = {value: @room.id}
    end
    #新しくルームを作るための画面を作る。
    def new
    end
    #新しくルームを作る処理を実装する。
    def create
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
end
