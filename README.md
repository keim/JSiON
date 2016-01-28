# JSiON
JSiON is a simple bridge from javascript to Flash SiON MML Player.

## How to use
- put "jsion.swf" and "jsion.js" on your page. and load "jsion.js"
```html:jsion.html
<script src="jsion.js"></script>
```
- create new instance of JSiON after the page is loaded, then call play method with mml text.
```javascript:usage.js
var jsion;

document.addEventListener("DOMContentLoaded", setup);

// [setup] create new JSiON instance with event handler 
function setup(){
    // When jsion.swf is put in different folder, set JSiON.swfURL.
    // JSiON.swfURL = "./swf/jsion.swf";

    // create instance with event handler
    var jsion = new JSiON(onSWFReady);
}

// ready to use
function onSWFReady() {
    jsion.play([mml string]); // compile and play mml
    jsion.stop();   // stop
    jsion.pause();  // pause
    jsion.resume(); // resume
    ...

    jsion.position([position]);   // set position in milli-second
    var pos = jsion.position();   // get position in milli-second

    jsion.volume([volume]);       // set master volume (0-1)
    var vol = jsion.volume();     // get master volume (0-1)
    ...
}
```

