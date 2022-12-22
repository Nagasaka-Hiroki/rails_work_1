import consumer from "./consumer"

consumer.subscriptions.create("RoomChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
    /*
    document.querySelector('.trix-content').addEventListener('keypress',(event)=>{
      if(event.key==='Enter'){
        //this.speak(event.target.value);
        console.log('hello');
        event.target.value='';
        return event.preventDefault();
      }
    });
    */
    const form_box = document.querySelector('.trix-content');
    document.querySelector(".send_content").addEventListener('click', (event)=>{
      console.log('hello');
      return event.preventDefault();
    });
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    //const element = document.querySelector('#messages');
    //element.insertAdjacentHTML('beforeend', data['message']);
  },

  speak: function() {
    //return this.perform('speak', {content: content});
  }
});
