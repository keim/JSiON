package {
    import flash.display.Sprite;
    import flash.system.Security;
    import flash.external.ExternalInterface;
    import flash.media.*;
    import flash.net.URLRequest;
    import flash.events.*;
    import org.si.sion.*;
    import org.si.sion.module.*;
    import org.si.sion.sequencer.*;
    import org.si.sion.events.*;
    import org.si.sion.utils.*;
    
    [SWF(frameRate='10')]
    public class jsion extends Sprite {
        public var driver:SiONDriver = new SiONDriver();
        public var dataList:Array = [];
        public var presetVoice:SiONPresetVoice = new SiONPresetVoice();
        public var soundTable:* = {};
        public var sionData:SiONData;
        public var mml:String;
        
        function jsion() {
            Security.allowDomain("*");
            
            driver.autoStop = true;
            driver.debugMode = true;

            sionData = new SiONData();
            MMLTalksParser.initialize(driver, _onError, _onLoadingProgress);
            
            // register javascript interfaces
            ExternalInterface.addCallback("_play",    _play);
            ExternalInterface.addCallback("_stop",    _stop);
            ExternalInterface.addCallback("_pause",   driver.pause);
            ExternalInterface.addCallback("_resume",  driver.play);
            ExternalInterface.addCallback("_volume",  _volume);
            ExternalInterface.addCallback("_pan",     _pan);
            ExternalInterface.addCallback("_position",_position);
            ExternalInterface.addCallback("_bpm",     _bpm);
            ExternalInterface.addCallback("_presetvoice", _presetvoice);

            // register handlers
            driver.addEventListener(ErrorEvent.ERROR,             _onError);
            driver.addEventListener(SiONEvent.STREAM_START,       _onStreamStart);
            driver.addEventListener(SiONEvent.STREAM_STOP,        _onStreamStop);
            driver.addEventListener(SiONEvent.FADE_IN_COMPLETE,   _onFadeInComplete);
            driver.addEventListener(SiONEvent.FADE_OUT_COMPLETE,  _onFadeOutComplete);
            driver.addEventListener(SiONTrackEvent.CHANGE_BPM,    _onChangeBPM);
            
            ExternalInterface.call('JSiON.__onLoad', SiONDriver.VERSION);
        }
        
        
    // call javascript
    //--------------------------------------------------
        private function _onError(e:ErrorEvent)          : void { _error(e.text); }
        private function _onLoadingProgress(e:ProgressEvent) : void { ExternalInterface.call('JSiON.__onLoadingProgress'); }
        private function _onStreamStart(e:SiONEvent)     : void { ExternalInterface.call('JSiON.__onStreamStart'); }
        private function _onStreamStop(e:SiONEvent)      : void { ExternalInterface.call('JSiON.__onStreamStop'); }
        private function _onFadeInComplete(e:SiONEvent)  : void { ExternalInterface.call('JSiON.__onFadeInComplete'); }
        private function _onFadeOutComplete(e:SiONEvent) : void { ExternalInterface.call('JSiON.__onFadeOutComplete'); }
        private function _onChangeBPM(e:SiONTrackEvent)  : void { ExternalInterface.call('JSiON.__onChangeBPM', driver.bpm); }
        
        
    // callback from javascript
    //--------------------------------------------------
        private function _play(...args) : void {
            var fadeTime:Number = Number(args[1]);
            driver.fadeIn((isNaN(fadeTime)) ? 0 : fadeTime);
            mml = String(args[0]);
            MMLTalksParser.parseMTSystemCommandBeforeCompile(mml, _onAllSoundLoaded);
        }

        private function _onAllSoundLoaded() : void {
            driver.compile(mml, sionData);
            MMLTalksParser.parseMTSystemCommandAfterCompile(sionData);
            mml = null;
            driver.play(sionData);
        }
        
        private function _stop(...args) : void {
            var fadeTime:Number = Number(args[0]);
            if (!isNaN(fadeTime)) driver.fadeOut(fadeTime);
            else driver.stop();
        }
        
        private function _volume(...args) : * {
            var vol:Number = Number(args[0]);
            if (!isNaN(vol)) driver.volume = (vol<0) ? 0 : (vol>1) ? 1 : vol;
            return driver.volume;
        }
    
        private function _pan(...args) : * {
            var pan:Number = Number(args[0]);
            if (!isNaN(pan)) driver.pan = (pan<-1) ? -1 : (pan>1) ? 1 : pan;
            return driver.pan;
        }
        
        private function _position(...args) : * {
            var pos:Number = Number(args[0]);
            if (!isNaN(pos)) driver.position = pos;
            return driver.position;
        }
        
        private function _bpm(...args) : * {
            var bpm:Number = Number(args[0]);
            if (!isNaN(bpm)) driver.bpm = bpm;
            return driver.bpm;
        }

        private function _error(text:String) : void { 
            ExternalInterface.call('JSiON.__onError', text);
        }

        private function _loadsound(...args) : * {
            if (args[0] is String) {
                MMLTalksParser.setURL(args[0] as String);
            }
        }
        
        private function _presetvoice(...args) : * {
            var ret:String = _getPresetMML(args[0]);
            if (ret == "") _error("SiONPresetVoice: key string not available")
            return ret;
        }

        

    // internal use
    //--------------------------------------------------
        private function _getPresetMML(key:*) : String {
            if (key is String) {
                var res:* = presetVoice[key as String];
                if (res is Array) {
                    var ret:Array = [];
                    for (var i:int=0; i<res.length; i++) {
                        ret[i] = JSON.stringify(res[i].getMML());
                    }
                    return JSON.stringify(ret);
                } else if (res is SiONVoice) {
                    return res.getMML();
                }
            }
            return "";
        }
    }
}
