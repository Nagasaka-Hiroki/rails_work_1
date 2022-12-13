/*ブラウザバックを禁止する。 */

////history.pushState(null,null,location.href);
//const iamhere = new URL(window.location);
//history.pushState(null,'',iamhere);
////document.addeventlistenerの方が強力。
//window.addEventListener('popstate',(event)=>{
//    history.go(1);
//    //const req = new Request(location.href);
//    //fetch(req);
//});


//window.addEventListener('load',(event)=>{
//    console.log('loaded!');
//});

const request_header = {'credentials':'omit'};
const iamhere = new URL(window.location);
history.pushState(null,'',iamhere);
window.addEventListener('popstate',(event)=>{
    //リロードさせた方が確実だと思う。
    history.go(1);
    window.location.reload();
    //const client_req = new Request(iamhere,request_header);
    //fetch(client_req);
});