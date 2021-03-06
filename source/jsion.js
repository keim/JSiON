/** 
 * JSiON is a javascript Bridge for Flash SiONDriver'S MML engine.
 * @constructor
 * @param {function} onLoad callback function when ready to use JSiON
 */
function JSiON(onLoad) {
    JSiON._initialize();
    JSiON.mutex = this;
    if (onLoad) this.onLoad = onLoad;
}


//----- status
/** 
 * Flag, true when ready to play
 * @type {boolean}
 */
JSiON.prototype.isReady = false;

/** 
 * Flag, true while playing
 * @type {boolean}
 */
JSiON.prototype.isPlaying = false;

/** 
 * Flag, true while pausing
 * @type {boolean}
 */
JSiON.prototype.isPaused = false;

/**
 * Track count
 * @type {int}
 */
JSiON.prototype.trackCount = 0;


//----- setter/getter
/** 
 * set volume
 * @param volume {Number} volume (0~1).
 */
JSiON.prototype.volume   = function() { JSiON.driver._volume(arguments[0]); };
/** 
 * set playing position
 * @param position {Number} playing position[ms].
 */
JSiON.prototype.position = function() { JSiON.driver._position(arguments[0]); };


//----- operation
/** 
 * Play mml string
 * @param mml {String} MML String to play
 * @param fadeInTime {Number} fade in time [ms]. default value = 0
 */
JSiON.prototype.play     = function(mml, fadeInTime) { JSiON.driver._play(mml, fadeInTime); };
/** 
 * Stop music
 * @param fadeOutTime {Number} fade out time [ms]. default value = 0
 */
JSiON.prototype.stop     = function(fadeOutTime) { JSiON.driver._stop(fadeOutTime); };
/** 
 * Pause music
 */
JSiON.prototype.pause    = function() { isPaused = true; JSiON.driver._pause(); };
/** 
 * Resume music
 */
JSiON.prototype.resume   = function() { isPaused = false; JSiON.driver._resume(); };
/** 
 * Load mp3 file refered from MML
 * @param url {String} mp3 file's url
 */
JSiON.prototype.loadSound= function(url) { JSiON.driver._loadsound(url); };
/** 
 * Apply mute table
 * @param table {Array<boolean>} track mute table set true to mute
 */
JSiON.prototype.applyMuteTable = function(table) { JSiON.driver._applymutetable(table.join(',')); };


//----- event handler
/**
 * callback when JSiON is loaded
 */
JSiON.prototype.onLoad = function() {};
/**
 * callback when start music
 */
JSiON.prototype.onStreamStart = function() {};
/**
 * callback when stop music
 */
JSiON.prototype.onStreamStop = function() {};
/**
 * callback when BPM is changed
 */ 
JSiON.prototype.onChangeBPM = function(bpm) {};
/**
 * callback when change BPM
 */ 
JSiON.prototype.onLoadingProgress = function(loaded, total) {};
/**
 * error callback
 */ 
JSiON.prototype.onError = function(text) { alert(text); };
/**
 * loading error callback
 */ 
JSiON.prototype.onLoadingError = function(text) { alert(text); };


//---------- 
/**
 * version number of JSiON
 */
JSiON.VERSION = '0.1.2';
/**
 * version number of SiON
 */
JSiON.SWF_VERSION = 'SWF has not loaded.';
/**
 * toString() returns version string
 */
JSiON.toString = function() { return 'JSiON_VERSION:' + JSiON.VERSION + '/ SWF_VERSION: ' + JSiON.SWF_VERSION; };
/**
 * DOM element ID for swf
 */
JSiON.domElementID = 'JSiON_DOM_ELEMENT';
/**
 * SiON swf object
 */
JSiON.driver = undefined;
/**
 * JSiON mutex object
 */
JSiON.mutex = undefined;
/**
 * Path for jsion.swf related from html
 */
JSiON.swfURL = 'jsion.swf';


//---------- internal functions
/** @private */
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

/** @private */
function getFlashPlayerVersion(subs) {
    return (navigator.appName.indexOf("Microsoft")==-1) ? 
        navigator.plugins["Shockwave Flash"].description.match(/([0-9]+)/)[subs] : 
        (new ActiveXObject("ShockwaveFlash.ShockwaveFlash")).GetVariable("$version").match(/([0-9]+)/)[subs];
}


//---------- callback functions from swf
/** @private */
JSiON.__onLoad = function(version) {
    JSiON.SWF_VERSION = version;
    JSiON.driver = document.getElementById(JSiON.domElementID);
    JSiON.mutex.isReady = true;
    JSiON.mutex.onLoad.call(JSiON.mutex);
};
/** @private */
JSiON.__onStreamStart = function(trackCount) {
    JSiON.mutex.trackCount = trackCount;
    JSiON.mutex.isPlaying = true;
    JSiON.mutex.onStreamStart.call(JSiON.mutex);
};
/** @private */
JSiON.__onStreamStop = function() {
    JSiON.mutex.onStreamStop.call(JSiON.mutex);
    JSiON.mutex.isPlaying = false;
    JSiON.mutex.trackCount = 0;
};

/** @private */
JSiON.__onError           = function(text) { JSiON.mutex.onError.call(JSiON.mutex, text); };
/** @private */
JSiON.__onLoadingProgress = function(loaded, total) { JSiON.mutex.onLoadingProgress.call(JSiON.mutex, loaded, total) };
/** @private */
JSiON.__onLoadingError    = function(text) { JSiON.mutex.onLoadingError.call(JSiON.mutex, text) };

