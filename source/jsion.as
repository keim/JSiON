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
    

    /** jsion: simple bridge to play SiON MML in javascript */
    public class jsion extends Sprite {
        /** SiON Driver to play */
        public var driver:SiONDriver = new SiONDriver();

        /** compiled SiONData */
        public var sionData:SiONData;

        /** list of muting track */
        public var muteTable:Array;


        
        
    // constructor
    //--------------------------------------------------
        /** constructor */
        function jsion() {
            Security.allowDomain("*");
            
            driver.autoStop = true;
            driver.debugMode = false;

            muteTable　= null;
            sionData = new SiONData();
            MMLTalksParser.initialize(driver, _onLoadingError, _onLoadingProgress);
            
            // register javascript interfaces
            ExternalInterface.addCallback("_play",    _play);
            ExternalInterface.addCallback("_stop",    _stop);
            ExternalInterface.addCallback("_pause",   driver.pause);
            ExternalInterface.addCallback("_resume",  driver.play);
            ExternalInterface.addCallback("_volume",  _volume);
            ExternalInterface.addCallback("_position",_position);
            ExternalInterface.addCallback("_loadsound",   _loadsound);
            ExternalInterface.addCallback("_applymutetable", _applymutetable);

            // register handlers
            driver.addEventListener(ErrorEvent.ERROR,       _onError);
            driver.addEventListener(SiONEvent.STREAM_START, _onStreamStart);
            driver.addEventListener(SiONEvent.STREAM_STOP,  _onStreamStop);
            
            ExternalInterface.call('JSiON.__onLoad', SiONDriver.VERSION);
        }
        


        
    // call javascript
    //--------------------------------------------------
        private function _onError(e:ErrorEvent) : void {
            _error(e.text);
        }


        private function _onStreamStart(e:SiONEvent) : void {
            _applyMuteTable2Driver();
            ExternalInterface.call('JSiON.__onStreamStart', driver.trackCount);
        }


        private function _onStreamStop(e:SiONEvent) : void {
            ExternalInterface.call('JSiON.__onStreamStop');
        }


        private function _onLoadingProgress(e:ProgressEvent) : void {
            ExternalInterface.call('JSiON.__onLoadingProgress', e.bytesLoaded, e.bytesTotal);
        }
        

        private function _onLoadingError(e:ErrorEvent) : void {
            ExternalInterface.call('JSiON.__onLoadingError', e.text); 
        }        
        



    // callback from javascript
    //--------------------------------------------------
        private function _play(...args) : void {
            var fadeTime:Number = Number(args[1]);
            driver.fadeIn((isNaN(fadeTime)) ? 0 : fadeTime);
            MMLTalksParser.compile(String(args[0]), _onCompileComplete, sionData);
        }


        private function _onCompileComplete(data:SiONData) : void {
            driver.play(data);
        }
        

        private function _stop(...args) : void {
            var fadeTime:Number = Number(args[0]);
            if (!isNaN(fadeTime) && fadeTime>0) driver.fadeOut(fadeTime);
            else driver.stop();
        }

        
        private function _volume(...args) : void {
            var vol:Number = Number(args[0]);
            if (!isNaN(vol)) driver.volume = (vol<0) ? 0 : (vol>1) ? 1 : vol;
        }


        private function _position(...args) : void {
            var pos:Number = Number(args[0]);
            if (!isNaN(pos)) driver.position = pos;
        }


        private function _error(text:String) : void { 
            ExternalInterface.call('JSiON.__onError', text);
        }


        private function _loadsound(...args) : * {
            if (args[0] is String) {
                MMLTalksParser.setURL(args[0] as String);
            }
        }


        private function _applymutetable(...args) : void {
            if (args.length == 0) {
                muteTable = null;
            } else {
                muteTable = (args[0] as String).split(",");
            }

            if (driver.isPlaying) _applyMuteTable2Driver();
        }

        


    // internal use
    //--------------------------------------------------
        private function _applyMuteTable2Driver() : void {
            var imax:int = driver.trackCount, i:int;
            if (muteTable == null) {
                for (i=0; i<imax; i++) {
                    driver.sequencer.tracks[i].mute = false;
                }
            } else {            
                if (imax > muteTable.length) imax = muteTable.length;
                for (i=0; i<imax; i++) {
                    driver.sequencer.tracks[i].mute = muteTable[i] as Boolean;
                }
            }
        }
    }
}
