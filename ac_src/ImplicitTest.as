package
{
	//TODO: sanitize keyboard inputs  (by adding another input handler function), add visual data
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getTimer;
	import flash.utils.ByteArray;

	public class ImplicitTest extends Sprite
	{
		//setting data
		//----------------------
		private var epochNum:int;
		private var epochLength:int;
//		private var settingsPath:String = LoaderInfo(this.root.loaderInfo).parameters.settingsPath;
//		private var collectorPath:String = LoaderInfo(this.root.loaderInfo).parameters.collectorPath;
		private var settingsPath:String = "test.json";
		private var collectorPath:String = "whaatever";

 		//----------------------
		
		//vars used to display stimuli etc.
		//----------------------
		private var textFormat:TextFormat;

		//----------------------

		
		private var keys:Dictionary = getKeyboardDict();
		private var loader:URLLoader;
		
		private var	desc1:Vector.<String> = new Vector.<String>();
		private var desc2:Vector.<String> = new Vector.<String>();
		private var desc1Key:String = 'desc1';
		private var desc2Key:String = 'desc2';
		private var descRef:Dictionary = new Dictionary();
		
		private var concept1:Vector.<String> = new Vector.<String>();
		private var concept2:Vector.<String> = new Vector.<String>();
		private var concept1Key:String = 'concept1';
		private var concept2Key:String = 'concept2';
		private var conceptRef:Dictionary = new Dictionary();
		private var inputRef:Object = {'E':concept1Key, 'I':concept2Key};
		private var intro:String;
		
		private var rule:Dictionary = new Dictionary();
		private var ruleStr:String;
		private var data:Dictionary = new Dictionary();
		private var result:Array = new Array();
		private var currentWord:String;
		private var timestamp:Number;
		
		private var currentEpoch:int = 0;
		private var stimuliShown:int = 0;
		
		public function ImplicitTest()
		{			
			init();
		}
			
		private function init():void{
			//prepare stage visually 
			stage.color = 0x000000;

			//simulate reading data
//			epochNum = 2;
//			epochLength = 6;
//			descRef[desc1Key] = "positive";
//			descRef[desc2Key] = "negative";
//			conceptRef[concept1Key] = "Me";
//			conceptRef[concept2Key] = "Others";
//			desc1 = new <String>["good","amaizing","wonderful","great"];
//			desc2 = new <String>["bad","awful","terrible","evil"];
//			concept1 = new <String>["me","mine","I","myself"];
//			concept2 = new <String>["they","them","others","people"];
//			//set initial rule and stimuli data
//			rule[concept1Key] = desc1Key;
//			rule[concept2Key] = desc2Key;
//			data[concept1Key] = shuffleVec(concept1.concat(desc1));
//			data[concept2Key] = shuffleVec(concept2.concat(desc2));
			
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, parseSettings);
			
			var settings:URLRequest = new URLRequest(settingsPath);
			try {
				loader.load(settings);
			} catch (error:Error) {
				trace("Unable to load requested document.");
			}
			
			//start test
//			showIntro();
		}
		
		private function parseSettings(event:Event):void{
			var loader:URLLoader = URLLoader(event.target);
			var settingsObj:Object = JSON.parse(loader.data);
			epochNum = settingsObj.epochNum;
			epochLength = settingsObj.epochLength;
			intro = settingsObj.intro;
			descRef[desc1Key] = settingsObj[desc1Key].name;
			descRef[desc2Key] = settingsObj[desc2Key].name;
			populateVec(desc1, settingsObj[desc1Key].words);
			populateVec(desc2, settingsObj[desc2Key].words);
			conceptRef[concept1Key] = settingsObj[concept1Key].name;
			conceptRef[concept2Key] = settingsObj[concept2Key].name;
			populateVec(concept1, settingsObj[concept1Key].words);
			populateVec(concept2, settingsObj[concept2Key].words);
			rule[concept1Key] = desc1Key;
			rule[concept2Key] = desc2Key;
			data[concept1Key] = shuffleVec(concept1.concat(desc1));
			data[concept2Key] = shuffleVec(concept2.concat(desc2));
			//			desc1 = new <String>(settingsObj[desc1Key].words);
			//			desc2 = new <String>["bad","awful","terrible","evil"];
			//			conceptRef[concept1Key] = "Me";
			//			conceptRef[concept2Key] = "Others";

			//			concept1 = new <String>["me","mine","I","myself"];
			//			concept2 = new <String>["they","them","others","people"];
			//			//set initial rule and stimuli data
			//			rule[concept1Key] = desc1Key;
			//			rule[concept2Key] = desc2Key;
			//			data[concept1Key] = shuffleVec(concept1.concat(desc1));
			//			data[concept2Key] = shuffleVec(concept2.concat(desc2));
			showIntro();
		}
		
		private function prepareStimuli():void {
			if(stimuliShown < epochLength){
				//show stimuli
				stimuliShown++;
				currentWord = chooseWord();
				displayWord(currentWord);
				timestamp = getTimer();
				stage.addEventListener(KeyboardEvent.KEY_DOWN, inputHandler);
			} else if(currentEpoch < epochNum){
				//start another epoch
				currentEpoch++;
				stimuliShown = 0;
				changeRule();
			} else {
				//finish
				var dbStr:String = "";
				var strRes:String = JSON.stringify(result);
				var request:URLRequest = new URLRequest(collectorPath);
				request.requestHeaders.push(new URLRequestHeader("Content-Type","application/json"));
				request.data = strRes;
				request.method = URLRequestMethod.POST;
				var urlLoader:URLLoader = new URLLoader();
				try
				{
					urlLoader.load(request);
					dbStr = "Спасибо за участие!";
				}
				catch(e:Error)
				{
					trace(e);
					dbStr = "Произошла ошибка!";
//					dbStr = e.message;
				}
				displayWord(dbStr);
			}
		}
		
		private function inputHandler(event:KeyboardEvent):void {
			var conceptKey:String = inputRef[keys[event.keyCode]];
			if(conceptKey != null){
				var reactionTime:Number = getTimer() - timestamp;
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, inputHandler);
				this.removeChildren(0, this.numChildren - 1);
				var correct:Boolean = this[conceptKey].indexOf(currentWord) >= 0 
					|| this[rule[conceptKey]].indexOf(currentWord) >= 0;
				var resObj:Object = {
					"word": currentWord,
					"rule": ruleStr,
					"time": reactionTime,
					"correct": correct
				};
				result.push(resObj);
				prepareStimuli();
			}
		}
		
		private function showRule(prompt:Boolean):void{
			textFormat = new TextFormat();
			textFormat.size = 18;
			textFormat.color = 0xFFFFFF;
			textFormat.align = TextFormatAlign.LEFT;
			
			var conceptKey:String = inputRef['E'];
			
			var ruleField:TextField = new TextField();
			ruleField.multiline = true;
			ruleField.wordWrap = true;
			ruleField.text = "Нажмите 'E' увидев что-то из категории\n" + conceptRef[conceptKey] + "\nили\n" +
				descRef[rule[conceptKey]];
			ruleField.setTextFormat(textFormat);
			ruleField.x = 0;
			ruleField.y = 0;
			ruleField.autoSize = TextFieldAutoSize.LEFT;
			addChild(ruleField);
			
			textFormat = new TextFormat();
			textFormat.size = 18;
			textFormat.color = 0xFFFFFF;
			textFormat.align = TextFormatAlign.RIGHT;
			
			conceptKey = inputRef['I'];
			
			ruleField = new TextField();
			ruleField.multiline = true;
			ruleField.wordWrap = true;
			ruleField.text = "Нажмите 'I' увидев что-то из категории\n" + conceptRef[conceptKey] + "\nили\n" +
				descRef[rule[conceptKey]];
			ruleField.setTextFormat(textFormat);
			ruleField.x = stage.stageWidth - ruleField.width;
			ruleField.y = 0;
			ruleField.autoSize = TextFieldAutoSize.RIGHT;
			addChild(ruleField);
			if(prompt){
				textFormat = new TextFormat();
				textFormat.color = 0xFFFFFF;
				textFormat.size = 16;
				textFormat.align = TextFormatAlign.CENTER;
			
				ruleField = new TextField();
				ruleField.width = stage.stageWidth;
				ruleField.scaleY = ruleField.scaleX;
				ruleField.multiline = true;
				ruleField.wordWrap = true;
				ruleField.text = "После того как вы прочитали и поняли правила, нажмите 'I' или 'E' чтобы продолжить.";
				ruleField.setTextFormat(textFormat);
				ruleField.x = stage.stageWidth / 2 - ruleField.width / 2;
				ruleField.y = stage.stageHeight - ruleField.textHeight;
				addChild(ruleField);
				stage.addEventListener(KeyboardEvent.KEY_DOWN, ruleHandler);
			}
		}
		
		private function ruleHandler(event:KeyboardEvent):void{
			if(inputRef[keys[event.keyCode]] != null){
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, ruleHandler);
				this.removeChildren(0, this.numChildren - 1);
				prepareStimuli();
			}
		}
		
		private function showIntro():void{
			textFormat = new TextFormat();
			textFormat.color = 0xFFFFFF;
			textFormat.size = 18;
			
			var introText:TextField = new TextField();
			
			introText.multiline = true;
			introText.wordWrap = true;
			introText.text = intro;
			introText.setTextFormat(textFormat);
			introText.width = stage.stageWidth;
			introText.scaleY = introText.scaleX;
			
			introText.x = stage.stageWidth / 2 - introText.textWidth / 2;
			introText.y = 0;
			
			addChild(introText);
			
			textFormat = new TextFormat();
			textFormat.size = 20;
			textFormat.color = 0xFF0000;
			
			var startLink:TextField = new TextField();
			var linkText:String = "Нажмите сюда чтобы начать!";
			
			startLink.htmlText = "<u><a href='event:myEvent'>"+linkText+"</a></u>";
			startLink.setTextFormat(textFormat);
			
			startLink.width = stage.stageWidth;
			startLink.scaleY = startLink.scaleX;
			
			startLink.x = stage.stageWidth / 2 - startLink.textWidth / 2;
			startLink.y = stage.stageHeight - startLink.textHeight;
			startLink.addEventListener(TextEvent.LINK, introHandler, false, 0, true);
			
			addChild(startLink);
		}
		
		private function introHandler(event:TextEvent):void{
			this.removeChildren(0, this.numChildren - 1);
			showRule(true);
		}
		
		private function displayWord(word:String):void{
			var hasDot:RegExp = /.*\..*/;
			if(hasDot.test(word)){
				loader = new URLLoader();
				loader.addEventListener(Event.COMPLETE, function(event:Event):void{
					var imgLoader = new Loader();
					imgLoader.loadBytes(loader.data);
					imgLoader.x = stage.stageWidth / 2 - imgLoader.content.width / 2;
					imgLoader.y = stage.stageHeight / 2 - imgLoader.content.height / 2;
					addChild(imgLoader);
					showRule(false);
				});
				loader.dataFormat = URLLoaderDataFormat.BINARY;
				
				var image:URLRequest = new URLRequest(word);
				try {
					loader.load(image);
				} catch (error:Error) {
					trace("Unable to load requested IMAGE.");
				}
			}else{
				textFormat = new TextFormat();
				textFormat.color = 0xFFFFFF;
				textFormat.size = 24;
				
				var wordField:TextField = new TextField();
				
				wordField.text = word;
				wordField.setTextFormat(textFormat);
				wordField.x = stage.stageWidth / 2 - wordField.textWidth / 2;
				wordField.y = stage.stageHeight / 2 - wordField.textHeight / 2;
				wordField.width = stage.stageWidth;
				wordField.scaleY = wordField.scaleX;
				addChild(wordField);
				showRule(false);
			}
		}
		
		private function chooseWord():String {
			var index:Vector.<String> = new <String>[concept1Key, concept2Key];
			var ri:int = randomIndex(index.length);
			var ckey:String = index[ri];
			ruleStr = conceptRef[ckey] + "/" + descRef[rule[ckey]];
			var drawBox:Vector.<String> = data[ckey];
			return drawBox.pop();
		}
		
		private function randomIndex(upperBound:int):int{
			return Math.floor(Math.random() * upperBound);
		}
		
		private function changeRule():void {
			var temp:String = rule[concept1Key];
			rule[concept1Key] = rule[concept2Key];
			rule[concept2Key] = temp;
			data[concept1Key] = shuffleVec(concept1.concat(this[rule[concept1Key]]));
			data[concept2Key] = shuffleVec(concept2.concat(this[rule[concept2Key]]));
			showRule(true);
		}
		
		private function shuffleVec(vec:Vector.<String>):Vector.<String>{
			var res:Vector.<String> = new Vector.<String>();
			while(vec.length > 0){
				res.push(vec.splice(randomIndex(vec.length), 1).pop());
			}
			return res;
		}
		
		private function populateVec(vec:Vector.<String>, obj:Object):void{
			for(var id:String in obj){
				vec.push(obj[id]);
			}
		}
		
		private function getKeyboardDict():Dictionary {
			var keyDesc:XML = describeType(Keyboard);
			var keyNames:XMLList = keyDesc..constant.@name;
			var keyboardDict:Dictionary = new Dictionary();
			var usedKeys:Vector.<String> = new <String>["E","I"];
			var keyName:String;
			
			for(var i:int = 0; i < keyNames.length(); i++){
				keyName = keyNames[i];
				if(usedKeys.indexOf(keyName) >= 0){
					keyboardDict[Keyboard[keyNames[i]]] = keyName;
				}
			}
			return keyboardDict;
		}
	}
}