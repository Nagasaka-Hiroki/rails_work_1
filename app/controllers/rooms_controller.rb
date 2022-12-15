class RoomsController < ApplicationController
    #すべての処理にログイン処理を付与する。
    before_action :basic_auth
    before_action :set_val, only: %i[ show ]
    #一覧を表示する。
    def index
        @user = session[:user]
        @rooms = @user.rooms
    end
    #履歴を表示する
    def show
        @chat_text = ChatText.new
    end
    #新しくルームを作るための画面を作る。
    def new
    end
    #新しくルームを作る処理を実装する。
    def create
    end

    #
    private
    def set_val
        @room = Room.find(params[:id])
    end

    #リッチテキストの内容を取得する。
    def content_params
        params.require(:chat_text).permit(:content)
    end
end
