// JSiON --- javascript Bridge for Flash SiONDriver
function JSiON(onLoad) {
    JSiON._initialize();
    JSiON.mutex = this;
    if (onLoad) this.onLoad = onLoad;
}

JSiON.prototype = {
//----- status
    isReady : false,
    isPlaying : false,
    isPaused : false,
    trackCount : 0,
//----- setter/getter
    volume   : function() { JSiON.driver._volume(arguments[0]); },
    position : function() { JSiON.driver._position(arguments[0]); },
//----- operation
    play     : function(mml, fadeInTime) { JSiON.driver._play(mml, fadeInTime); },
    stop     : function(fadeOutTime) { JSiON.driver._stop(fadeOutTime); },
    pause    : function() { isPaused = true; JSiON.driver._pause(); },
    resume   : function() { isPaused = false; JSiON.driver._resume(); },
    loadSound: function(url) { JSiON.driver._loadsound(url); },
    applyMuteTable : function(table) { JSiON.driver._applymutetable(table.join(',')); },
//----- event handler
    onLoad : function() {},
    onStreamStart : function() {},
    onStreamStop : function() {},
    onChangeBPM : function(bpm) {},
    onLoadingProgress : function(loaded, total) {},
    onError : function(text) { alert(text); },
    onLoadingError : function(text) { alert(text); }
};


//---------- 
JSiON.VERSION = '0.1.2';
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
    JSiON.mutex.isReady = true;
    JSiON.mutex.onLoad.call(JSiON.mutex);
};
JSiON.__onStreamStart = function(trackCount) {
    JSiON.mutex.trackCount = trackCount;
    JSiON.mutex.isPlaying = true;
    JSiON.mutex.onStreamStart.call(JSiON.mutex);
};
JSiON.__onStreamStop = function() {
    JSiON.mutex.onStreamStop.call(JSiON.mutex);
    JSiON.mutex.isPlaying = false;
    JSiON.mutex.trackCount = 0;
};

JSiON.__onError           = function(text) { JSiON.mutex.onError.call(JSiON.mutex, text); };
JSiON.__onLoadingProgress = function(loaded, total) { JSiON.mutex.onLoadingProgress.call(JSiON.mutex, loaded, total) };
JSiON.__onLoadingError    = function(text) { JSiON.mutex.onLoadingError.call(JSiON.mutex, text) };

