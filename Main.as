package 
{
	import flash.text.TextField;
	import flash.text.TextFormat;
	import fl.transitions.Tween;
	import fl.transitions.easing.Strong;
	import flash.display.Sprite;
	import flash.utils.setTimeout;
	import flash.display.MovieClip;
	import flash.media.Microphone;
	import flash.system.Security;
	import org.bytearray.micrecorder.*;
	import org.bytearray.micrecorder.events.RecordingEvent;
	import org.bytearray.micrecorder.encoder.WaveEncoder;
	import org.as3wavsound.WavSound;
	import flash.events.MouseEvent;
	import flash.events.SampleDataEvent;
	import flash.events.Event;
	import flash.events.ActivityEvent;
	import flash.net.FileReference;

	public class Main extends Sprite
	{
		private var mic:Microphone;
		private var waveEncoder:WaveEncoder = new WaveEncoder();
		private var recorder:MicRecorder = new MicRecorder(waveEncoder);
		private var recBar:RecBar = new RecBar();
		private var tween:Tween;
		private var fileReference:FileReference = new FileReference();
		private var recorded:WavSound;
		private var date = new Date();
		private var recorded_once:Boolean = false;
		private var recording:Boolean = false;
		private var playing:Boolean = false;
		private var rec_title:TextField = new TextField();
		private var title_format:TextFormat;
		private const MIN_LENGTH:uint = 1000;
		
		private var recButton = new btn_r();
		private var playButton = new btn_p();
		private var saveButton = new btn_d();
		private var vu_meter = new vumeter();

		public function Main():void
		{  
			title_format = new TextFormat();
			title_format.align = 'center';
			title_format.size = 20;
			title_format.font = 'HelveticaNeue LT 65 Medium';
			title_format.color = 0xAC1300;
			
			rec_title.defaultTextFormat = title_format;
			
			if(loaderInfo.parameters.title)
			{
				rec_title.text = loaderInfo.parameters.title;
			}
			else
			{
				rec_title.text = 'Simple AS3 Recorder';
			}
			
			rec_title.width = stage.width;
			rec_title.height = 25;
			rec_title.y = 35;
			rec_title.selectable = false;
			
			
			recButton.y = playButton.y = saveButton.y = 105;
			recButton.x = 69;
			playButton.x = vu_meter.x = 160;
			saveButton.x = 251;
			vu_meter.y = 150;
			vu_meter.alpha = 1;
			vu_meter.height = 10;
			
			addChild(rec_title);
			addChild(recButton);
			addChild(playButton);
			addChild(saveButton);
			addChild(vu_meter);
			
			updateButtons( [1, 3] );
			saveButton.gotoAndStop(3);
			vu_meter.stop();

			mic = Microphone.getMicrophone();
			mic.setSilenceLevel(0);
			mic.gain = 100;
			mic.setLoopBack(false);
			mic.setUseEchoSuppression(true);
			Security.showSettings('2');

			addListeners();
		}

		public function addListeners():void
		{
			recButton.addEventListener(MouseEvent.MOUSE_UP, startRecording);
			playButton.addEventListener(MouseEvent.MOUSE_UP, startPlaying);
			saveButton.addEventListener(MouseEvent.MOUSE_UP, saveRecording);
			
			recorder.addEventListener(RecordingEvent.RECORDING, disp_recording);
			recorder.addEventListener(Event.COMPLETE, recordComplete);
			
			vu_meter.addEventListener(Event.ENTER_FRAME, updateMeter);
		}



		/* --- PROCESSING FUNCTIONS --- */
		
		public function startRecording(e:MouseEvent):void
		{
			if (mic != null && !playing)
			{
				recording = true;
				recorder.record();
				e.target.gotoAndStop(2);
				
				if(saveButton.curentFrame != 3)
					saveButton.gotoAndStop(3);
				if(playButton.curentFrame != 3)
					playButton.gotoAndStop(3);

				recButton.removeEventListener(MouseEvent.MOUSE_UP, startRecording);
				recButton.addEventListener(MouseEvent.MOUSE_UP, stopRecording);

				recBar.width = stage.width;
				recBar.height = 40;
				addChild(recBar);

				tween = new Tween(recBar,"y",Strong.easeOut, -  (recBar.height/2+10),0,1,true);
			}
		}

		public function stopRecording(e:MouseEvent):void
		{
			recorder.stop();

			mic.setLoopBack(false);
			e.target.gotoAndStop(1);

			recButton.removeEventListener(MouseEvent.MOUSE_UP, stopRecording);
			recButton.addEventListener(MouseEvent.MOUSE_UP, startRecording);

			tween = new Tween(recBar,"y",Strong.easeOut,0, - (recBar.height/2+10),1,true);
		}

		public function recordComplete(e:Event):void
		{
			recording = false;
			recorded = new WavSound( recorder.output );
			
			if(recorded.length > MIN_LENGTH)
			{
				recorded_once = true;
				playButton.gotoAndStop(1);
				saveButton.gotoAndStop(1);
			}
		}
		
		public function startPlaying(e:Event):void
		{
			if(recorded_once && !playing && !recording)
			{
				playing = true;
				recorded.play();
				
				setTimeout(updateButtons, 1000, [3, 2] );
				//updateButtons( [3, 2] );
				playButton.removeEventListener(MouseEvent.MOUSE_UP, startPlaying);
				playButton.addEventListener(MouseEvent.MOUSE_UP, stopPlaying);
				
				setTimeout(stopPlaying, recorded.length, new MouseEvent(MouseEvent.MOUSE_UP));	
			}
		}
		
		public function stopPlaying(e:Event):void
		{
			playing = false;
			recorded.stop();
			
			setTimeout(updateButtons, 1000, [1, 1] );
			
			playButton.removeEventListener(MouseEvent.MOUSE_UP, stopPlaying);
			playButton.addEventListener(MouseEvent.MOUSE_UP, startPlaying);			
			
		}
		
		public function saveRecording(e:Event):void
		{
			if(!recording && recorded_once && recorded.length > MIN_LENGTH)
			{
				var file_name:String;
				
				if(date.getMonth() < 10)
					file_name = '0' + date.getMonth() + '-';
				else
					file_name = date.getMonth() + '-';
					
				if(date.getDate() < 10)
					file_name += '0' + date.getDate() + '-' + date.getFullYear();
				else
					file_name += date.getDate() + '-' + date.getFullYear();				
				
				
				file_name = 'e-Client ' +
							file_name
							+ '_' +
							date.getHours()
							+'.'+
							date.getMinutes();
							
				fileReference.save(recorder.output, file_name + '.wav');
			}
		}
		
		
		/* --- DISPLAY FUNCTIONS --- */
		
		private function disp_recording(e:RecordingEvent):void
		{
			var currentTime:int = Math.floor(e.time / 1000);

			recBar.counter.text = String(currentTime);

			if (String(currentTime).length == 1)
			{
				recBar.counter.text = "00:0" + currentTime;
			}
			else if (String(currentTime).length == 2)
			{
				recBar.counter.text = "00:" + currentTime;
			}
		}
		
		private function updateMeter(e:Event):void
		{
			vu_meter.gotoAndPlay(100 - mic.activityLevel);
		}
		
		private function updateButtons(frames:Array):void
		{
			recButton.gotoAndStop(frames[0]);	
			playButton.gotoAndStop(frames[1]);
		}
		
	} //fin de classe
} //fin de package