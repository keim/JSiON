// JSiON --- javascript Bridge for Flash SiONDriver
function JSiON(onLoad) {
    JSiON._initialize();
    JSiON.mutex = this;
    if (onLoad) this.onLoad = onLoad;
}

JSiON.prototype = {
//----- status
    isLoaded : false,
    isStreaming : false,
    isPaused : false,
//----- setter/getter
    volume   : function() { return JSiON.driver._volume(arguments[0]); },
    pan      : function() { return JSiON.driver._pan(arguments[0]); },
    position : function() { return JSiON.driver._position(arguments[0]); },
    bpm      : function() { return JSiON.driver._bpm(arguments[0]); },
//----- operation
    play     : function(mml, fadeInTime) { JSiON.driver._play(mml, fadeInTime); },
    stop     : function(fadeOutTime) { JSiON.driver._stop(fadeOutTime); },
    pause    : function() { JSiON.driver._pause(); },
    resume   : function() { JSiON.driver._resume(); },
    loadSound: function(url) { JSiON.driver._loadsound(key, url); },
    presetVoiceMML : function(key) { return JSiON.driver._presetvoice(key); },
//----- event handler
    onLoad : function() {},
    onStreamStart : function() {},
    onStreamStop : function() {},
    onFadeInComplete : function() {},
    onFadeOutComplete : function() {},
    onChangeBPM : function(bpm) {},
    onError : function(text) { alert(text); }
};


//---------- 
JSiON.VERSION = '0.1.1';
JSiON.SWF_VERSION = 'SWF has not loaded.';
JSiON.toString = function() { return 'JSiON_VERSION:' + JSiON.VERSION + '/ SWF_VERSION: ' + JSiON.SWF_VERSION; };
JSiON.domElementID = 'JSiON_DOM_ELEMENT';
JSiON.driver = undefined;
JSiON.mutex = undefined;
JSiON.swfURL = 'jsion.swf';

//---------- internal functions
JSiON._initialize = function() {
    if (JSiON.mutex) throw "Cannot create plural JSiON instances";
    if (getFlashPlayerVersion(0) < 10) throw "flash player 10 is required";
    var o = document.createElement('object');
    o.id = JSiON.domElementID;
    o.classid = 'clsid:D27CDB6E-AE6D-11cf-96B8-444553540000';
    o.width = '1';
    o.height = '1';
    o.setAttribute('data', JSiON.swfURL);
    o.setAttribute('type', 'application/x-shockwave-flash');
    var p = document.createElement('param');
    p.setAttribute('name', 'allowScriptAccess');
    p.setAttribute('value', 'always');
    o.appendChild(p);
    document.body.appendChild(o);
};

function getFlashPlayerVersion(subs) {
    return (navigator.appName.indexOf("Microsoft")==-1) ? 
        navigator.plugins["Shockwave Flash"].description.match(/([0-9]+)/)[subs] : 
        (new ActiveXObject("ShockwaveFlash.ShockwaveFlash")).GetVariable("$version").match(/([0-9]+)/)[subs];
}

//---------- callback functions from swf
JSiON.__onLoad = function(version) {
    JSiON.SWF_VERSIOPM = version;
    JSiON.driver = document.getElementById(JSiON.domElementID);
    JSiON.mutex.onLoad.call(JSiON.mutex);
};
JSiON.__onStreamStart     = function() { JSiON.mutex.onStreamStart(JSiON.mutex); };
JSiON.__onStreamStop      = function() { JSiON.mutex.onStreamStop(JSiON.mutex); };
JSiON.__onFadeInComplete  = function() { JSiON.mutex.onFadeInComplete(JSiON.mutex); };
JSiON.__onFadeOutComplete = function() { JSiON.mutex.onFadeOutComplete(JSiON.mutex); };
JSiON.__onChangeBPM       = function(bpm) { JSiON.mutex.onChangeBPM(bpm); };
JSiON.__onError           = function(text) { JSiON.mutex.onError(text); };
JSiON.__onLoadingProgress = function(key) {};
JSiON.__onLoadingError    = function(key) {};

