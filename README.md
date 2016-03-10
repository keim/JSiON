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
    jsion = new JSiON(onSWFReady);
}

// ready to use
function onSWFReady() {
    jsion.play([mml string]); // compile and play mml
    jsion.stop();   // stop
    jsion.pause();  // pause
    jsion.resume(); // resume
    ...

    jsion.position([position]);   // set position in milli-second
    jsion.volume([volume]);       // set master volume (0-1)
    ...

    jsion.isReady
    jsion.isPlaying
    jsion.isPaused
    jsion.trackCount
    ...
}
```

([option] SiONPresetVoice.js includes preset voice mml.)

```javascript:usage_preset.js
var voices = new SiONPresetVoice(); // create new instance.

var pianovoice = voices["valsound.piano1"];
console.log(pianovoice.name);   // "Aco Piano2 (Attack)"
console.log(pianovoice.mml);    // "#OPN@0{...(params)...};"

var pianolist = voices["valsound.piano"];
console.log(pianolist[0].name); // "Aco Piano2 (Attack)"
console.log(pianolist[0].mml);  // "#OPN@0{...(params)...};"

var pianolist2 = voices.categolies[7];
console.log(pianolist2[0].name); // "Aco Piano2 (Attack)"
console.log(pianolist2[0].mml);  // "#OPN@0{...(params)...};"
```