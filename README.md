# JSiON
JSiON is a simple bridge from javascript to Flash SiON MML Player.

## How to use
1. put "jsion.swf" and "jsion.js" on your page.
2. load "jsion.js"
```html:jsion.html
<script src="jsion.js"></script>
```
3. create new instance of JSiON after the page is loaded, then call play method with mml text.
```javascript:usage.js
document.onload = function(){
    var jsion = new jSiON();
    ...
    jsion.play([mml string]);
}
```

