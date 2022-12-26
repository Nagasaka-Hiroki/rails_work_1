import consumer from "./consumer"

consumer.subscriptions.create("RoomChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
    
    //フォームテキストボックスの要素を取り出す。
    const form_text_box = document.querySelector('#action_text_box');

    //フォームで入力後にshift + Enterで送信する。
    form_text_box.addEventListener('keydown',(event)=>{
      //shift + Enterが押されない場合は即時リターンする。
      //ド・モルガンの法則。許可するのは次のパターン。(event.key==='Enter' && event.shiftKey)。
      if(event.key!=='Enter' || !event.shiftKey){
        return;
      }

      //フィルターに使う正規表現を定義する
      //htmlタグ内の要素を抽出する。以下の正規表現で改行タグ<br>以外を取り除ける。
      const filter_innerHTML = new RegExp('(?<=<.*?>).*?(?=<\/.*?>)','gis');
      //まずマッチするか確かめる。これはバグ防止。マッチせずに進んだ場合以下がエラーになる。
      if (filter_innerHTML.test(event.target.value)) {
        //マッチした場合マッチした内容を配列に変換する。
        const input_text_array = event.target.value.match(filter_innerHTML);
        //配列の内容を一つの文字列に変換する。
        const input_text = input_text_array.join("");
        //文字列を置換して<br>を取り除く。また空白も取り除く。&nbsp;は直接変換する。
        //ノーブレークスペースは先頭と末尾の半角スペース、連続する半角スペースの２つ目以降に該当するようだ。
        const reject_br = new RegExp('<br>|[\s]+|&nbsp;','g');
        const remaining_text = input_text.replaceAll(reject_br, "");
        //<br>を取り除いた後にテキストが残っているか判定する。
        //残っている場合（空白ではない場合）、入力情報有りとして処理する。
        if (remaining_text!=="") {
          this.speak(event.target.value);
          event.target.value='';
        }
      }
      return event.preventDefault();

      //原型
      //空白or改行だけの入力を防止する処理を追加すれば上記になる。
      //if(event.key==='Enter' && event.shiftKey){
      //  this.speak(event.target.value);
      //  event.target.value='';
      //  return event.preventDefault();
      //}
    });
    //送信ボタンでも送信できるようにする。
    document.querySelector("#send_button").addEventListener('click', (event)=>{
      //イベントを発生させるためのイベントオブジェクトを作る。
      const press_shift_enter = new Event('keydown');
      //キーの状態を再現する。
      press_shift_enter.key = 'Enter';
      press_shift_enter.shiftKey = true;
      //今フォームにid=action_text_boxを設定している。それを元にtargetを割り当てる。
      press_shift_enter.target = document.querySelector("#action_text_box");
      //新しく作ったイベントオブジェクトを元にフォームイベントを発生させる。
      form_text_box.dispatchEvent(press_shift_enter);
      return event.preventDefault();
    });
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    const chat_log = document.querySelector('#chat_log');
    chat_log.insertAdjacentHTML('beforeend', data["content"]);
    //console.log(data);
    //console.log(data["content"]);
  },

  speak: function(content) {
    //ハッシュにアクセスできるようにするイメージでデータを渡す。
    return this.perform('speak', {content: content});
  }
});
