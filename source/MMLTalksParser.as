package {
    import flash.events.*;
    import flash.media.*;
    import flash.net.*;
    import flash.utils.*;
    import org.si.sion.*;
    import org.si.sion.sequencer.*;
    import org.si.sion.module.SiOPMTable;
    import org.si.sion.utils.*;
    import org.si.sion.utils.soundloader.*;
    import mx.utils.Base64Decoder;
    import mx.utils.Base64Encoder;
    
    
    // System command specialized for MMLTalks
    public class MMLTalksParser {
    // variables
    //--------------------------------------------------
        static public var presetVoices:SiONPresetVoice = null;
        static public var soundHash:* = null;
        
        static private var _sionDriver:SiONDriver = null;
        static private var _soundLoader:SoundLoader = null;
        static private var _errorHandler:Function = null;
        static private var _completeHandler:Function = null;
        static private var _progressHandler:Function = null;
        
        
        
    // event handler
    //--------------------------------------------------
        static private function _onError(e:ErrorEvent) : void {
            if (_errorHandler != null) _errorHandler(e);
        }
        
        
        static private function _onProgress(e:ProgressEvent) : void {
            if (_progressHandler != null) _progressHandler(e);
        }


        
    // commands
    //--------------------------------------------------
        /** call this first after create new SiONDriver */
        static public function initialize(driver:SiONDriver, onError:Function, onProgress:Function) : void {
            _sionDriver = driver;
            _soundLoader = new SoundLoader(0, true, true, true);
            _soundLoader.addEventListener(Event.COMPLETE, _onCompleteAll);
            _soundLoader.addEventListener(ErrorEvent.ERROR, _onError);
            _soundLoader.addEventListener(ProgressEvent.PROGRESS, _onProgress);
            _errorHandler = onError;
            _progressHandler = onProgress;
        }
        
        
        /** callback while system command parsing. you have to copmle MML after all sound loaded. */
        static public function parseMTSystemCommandBeforeCompile(mml:String, onAllSoundLoaded:Function) : void {
            var cmds:Array = Translator.extractSystemCommand(mml), cmd:*, array:Array, ba:ByteArray, src:ByteArray, 
                i:int, url:String, fileData:SoundLoaderFileData;

            // list all Sound requires loading
            for (i=0; i<cmds.length; i++) {
                cmd = cmds[i];
                switch(cmd.command){
                case "#LOADSOUND":
                    //data
                    url = cmd.content;
                    fileData = _soundLoader.setURL(new URLRequest(url), url);
                    break;
                }
            }

            // load all
            _completeHandler = onAllSoundLoaded;
            _soundLoader.loadAll();
        }
        
        
        /** analyze MMLTalks system commands. */
        static public function parseMTSystemCommandAfterCompile(data:SiONData) : void {
            var voice:SiONVoice, offset:int, i:int;
            
            for each (var cmd:* in data.systemCommands) {
                switch(cmd.command){
                case "#PRESET@":
                    if (!presetVoices) presetVoices = new SiONPresetVoice();
                    voice = presetVoices[cmd.content];
                    if (voice is SiONVoice) data.setVoice(cmd.number, voice);
                    break;
                }
            }
        }


        /** set url to load */
        static public function setURL(url:String) : SoundLoaderFileData {
            return _soundLoader.setURL(new URLRequest(url), url);
        }
        
        
        // on complete all
        static private function _onCompleteAll(e:Event) : void {
            var key:String, index:int, fileRex:RegExp = /\/((.+?)\..*)$/, res:*; 
            // construct sound hash table and font list
            soundHash = {};
            for (key in _soundLoader.hash) {
                if (_soundLoader.hash[key] is Sound) {
                    res = fileRex.exec(key);
                    if (res) {
                        if (res[1] != "") soundHash[res[1]] = _soundLoader.hash[key];
                        if (res[2] != "") soundHash[res[2]] = _soundLoader.hash[key];
                    }
                }
            }
            // set sound hash table
            _sionDriver.setSoudReferenceTable(soundHash);
            
            // usually comple MML here
            _completeHandler();
            _completeHandler = null;
        }
    }
}
