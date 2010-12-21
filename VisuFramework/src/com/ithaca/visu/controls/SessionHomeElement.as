package com.ithaca.visu.controls
{
	import com.ithaca.visu.dataStrutures.UserSwapList;
	import com.ithaca.visu.events.SessionHomeElementEvent;
	import com.ithaca.visu.renderer.ConnectedUserListRenderer;
	import com.ithaca.visu.renderer.ConnectedUserRenderer;
	import com.ithaca.visu.renderer.ConnectedUserWithListRenderer;
	import com.ithaca.visu.ui.utils.ConnectionStatus;
	import com.ithaca.visu.ui.utils.RoleEnum;
	import com.ithaca.visu.ui.utils.SessionStatusEnum;
	import com.lyon2.utils.TimeUtils;
	import com.ithaca.visu.model.Session;
	import com.ithaca.visu.model.User;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	import gnu.as3.gettext.FxGettext;
	import gnu.as3.gettext._FxGettext;
	
	import mx.collections.ArrayList;
	import mx.collections.IList;
	import mx.collections.Sort;
	import mx.controls.Button;
	import mx.core.ClassFactory;
	import mx.events.StateChangeEvent;
	import mx.formatters.DateFormatter;
	import mx.graphics.shaderClasses.HueShader;
	import mx.states.OverrideBase;
	
	import spark.components.DataGroup;
	import spark.components.RichText;
	import spark.components.SkinnableContainer;
	import spark.components.supportClasses.ButtonBase;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.components.supportClasses.TextBase;
	import spark.utils.TextFlowUtil;
	
	[SkinState("normal")]
	[SkinState("open")]
	[SkinState("disabled")]
	
	public class SessionHomeElement extends SkinnableComponent
	{
		[SkinPart("true")]
		public var openButton:ButtonBase;
		
		[SkinPart("true")]
		public var hourDisplay:TextBase;
		
		[SkinPart("true")]
		public var titleDisplay:TextBase;

		[SkinPart("true")]
		public var subDisplay:RichText;
		
		[SkinPart("true")]
		public var users:DataGroup;
		
		[SkinPart("false")]
		public var connectButton:ButtonBase;
		
		[SkinPart("false")]
		public var editButton:ButtonBase;
		
		[SkinPart("false")]
		public var cancelButton:ButtonBase;
		
		public var editable:Boolean;
		public var loggedUser:User;
		
		protected var open:Boolean;
		protected var recording:Boolean;
		protected var recordingMessage:String;
		
		[Bindable]
		private var fxgt:_FxGettext;
		
		private var _session:Session;
		private var sessionChanged:Boolean;
		public function get session():Session
		{
			return _session;
		}
		public function set session(value:Session):void
		{
			sessionChanged = true;
			_session = value;
			// ercording date of fthis session
			var dateRecording:Date = _session.date_start_recording;
			// set status the session
			switch (_session.statusSession) {
				case SessionStatusEnum.SESSION_OPEN:
					open = true;
					break;
				case SessionStatusEnum.SESSION_CLOSE:
					open = false;
					enabled = false;
					recording = false;
					break;
				case SessionStatusEnum.SESSION_RECORDING:
					open = true;
					recording = true;
					recordingMessage = fxgt.gettext("La séance a été démarré de ")+dateRecording.getHours().toString()+fxgt.gettext("h ")+dateRecording.getMinutes().toString()+fxgt.gettext("m");
					break;
				case SessionStatusEnum.SESSION_PAUSE:
					open = true;
					recording = true;
					recordingMessage = fxgt.gettext("La séance a été démarré de ")+dateRecording.getHours().toString()+fxgt.gettext("h ")+dateRecording.getMinutes().toString()+fxgt.gettext("m") + fxgt.gettext(" : Suspendue...");
					break;
			}
			
			invalidateProperties();
		}
		
		
		private var _swapItems:IList;
		private var swapItemsChanged:Boolean;
		public function get swapItems():IList
		{
			return _swapItems;
		}
		public function set swapItems(value:IList):void
		{
			swapItemsChanged = true;
			_swapItems = value;
			invalidateProperties();
		}
		
		
		
		private var hourformater:DateFormatter; 
		
		public function SessionHomeElement()
		{
			super();
			hourformater=new DateFormatter();
			hourformater.formatString = "HH:NN";
			fxgt = FxGettext;
		}
		
		
		override protected function partAdded(partName:String, instance:Object):void
		{			 
			if (instance==openButton)
			{
				openButton.addEventListener(MouseEvent.CLICK,openView);
			}
			if (instance==users) 
			{
				users.itemRendererFunction = function(item:Object):ClassFactory
				{
					var className:Class = ConnectedUserRenderer;
					var u:UserSwapList = UserSwapList(item);

					
					
					if( editable && u.user.status != ConnectionStatus.CONNECTED && u.user.status != ConnectionStatus.RECORDING ) 
						className = ConnectedUserWithListRenderer;
					return new ClassFactory( className);
				};
				
				updateViewUsers();
				
			}			
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			if (instance==openButton)
			{
				openButton.removeEventListener(MouseEvent.CLICK,openView);
			}
			if (instance==users) trace("remove listener");
		}
		
		override protected function getCurrentSkinState():String
		{
			return !enabled? "disabled" : open? "open" : "normal";
		}
		 
		override protected function commitProperties():void
		{
			super.commitProperties();
			if (sessionChanged)
			{
				if (session != null)
				{
					hourDisplay.text = hourformater.format(session.date_session);
					
					titleDisplay.text = session.theme;
				}
			}
/*			if(!open && !recording && !enabled )
			{
				openButton.toolTip = fxgt.gettext("La séance a eu lieu le ")+this._session.date_start_recording.toLocaleString();
			}*/
		}
		
		override protected function measure():void
		{
			super.measure();
			measuredHeight 
				= titleDisplay.measuredHeight 
				+ subDisplay.measuredHeight;
			if( users  ) 
			{ 
				var nbrUsers:uint = users.numElements;
				// try to calcul height the part users
				measuredHeight += (nbrUsers/2 + 1)*22 + 60;
			}
			measuredMinHeight = measuredHeight;
		}
		
		
		/**
		 * 
		 * Overriding stateChanged in order to update skinPart Content 
		 * 
		 */
		override protected function stateChanged(oldState:String, newState:String, recursive:Boolean):void
		{
			super.stateChanged(oldState,newState,recursive);
			switch (newState)
			{
				case "open":
					subDisplay.textFlow = TextFlowUtil.importFromString(remaining_time);
					if (recording )
					{
						subDisplay.textFlow = TextFlowUtil.importFromString(recordingMessage);
						subDisplay.setStyle("color", "#da3939"); 
					}				
					break;
				default:
					subDisplay.textFlow = TextFlowUtil.importFromString(participants);	
					subDisplay.setStyle("color", "#000000"); 
					break;
			}
		}
		
		
		/**
		 * 
		 * this function executes when the openButton dispatch a MouseEvent.CLICK 
		 * 
		 */
		protected function openView(event:MouseEvent):void
		{
			open=!open;
			currentState=="normal" ? "open": "normal";
			invalidateSkinState();
		}
		
		public function updateViewUsers():void{
			if(users != null){
				var d:IList = new ArrayList();
				for each( var u:User in _session.participants)
				{
					d.addItem( new UserSwapList( u, _swapItems ) );
				}
				users.dataProvider = d;				
			}
			// recording date of this session
			var dateRecording:Date = _session.date_start_recording;
			if(_session.statusSession == SessionStatusEnum.SESSION_RECORDING)
			{
				recording = true;
				
				if(dateRecording != null){
					recordingMessage = fxgt.gettext("La séance a été démarré il y a ")+dateRecording.getHours().toString()+fxgt.gettext("h ")+dateRecording.getMinutes().toString()+fxgt.gettext("m");			
				}else{
					recordingMessage "date == NULL";
				}
			}else if(_session.statusSession == SessionStatusEnum.SESSION_PAUSE)
			{
				recording = true;
				recordingMessage = fxgt.gettext("La séance a été démarré il y a ")+dateRecording.getHours().toString()+fxgt.gettext("h ")+dateRecording.getMinutes().toString()+fxgt.gettext("m") + fxgt.gettext(" : Suspendue...");
			}else if(_session.statusSession == SessionStatusEnum.SESSION_CLOSE)
			{
				open = false;
				enabled = false;
				recording = false;
			}
				
			invalidateSkinState();
		}
		
/*		public function setOpenView(value:Boolean):void
		{
			open=value;
			invalidateSkinState();
		}*/
		
/*		public function setEnabledView(value:Boolean):void
		{
			enabled=value;
			invalidateSkinState();
		}*/
		
		/* Helper functions */
		
		/**
		 * @return string reprensentation of the remaining time before session start.
		 */ 
		protected function get remaining_time():String
		{
			var translate:String = fxgt.gettext("La séance devait commencer ");
			var diff:Number = new Date().time - _session.date_session.time;
			if(diff < 0)
			{
				translate = fxgt.gettext("La séance commencera ");				
			}
			return "<p textAlign='center'  fontSize='10'>"+translate+"<span fontWeight='bold'>"
					+ TimeUtils.relativeTime(_session.date_session,null,true)
					+"</span></p>";
		}
		 		
		/**
		 * return String a textflow markup string representation of the session participants
		 * (tutor are placed in front, in bold, followed by students 
		 */
		protected function get participants():String
		{
			var a:Array=[];
			for each(var user:User in _session.participants)
			{
				if( user.role > RoleEnum.STUDENT )
				{
					a.splice(0,0,'<span fontWeight="bold">'+user.firstname+'</span>') ;
				}
				else
				{
					a.push(user.firstname);
				}
			} 
			return a.join(", ");
		}
		
	}
}