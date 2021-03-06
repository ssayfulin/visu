package com.ithaca.visu.view.user
{
	import com.ithaca.visu.controls.AdvancedTextInput;
	import com.ithaca.visu.controls.users.UserDetail;
	import com.ithaca.visu.controls.users.UserFilters;
	import com.ithaca.visu.controls.users.event.UserFilterEvent;
	import com.lyon2.controls.utils.LemmeFormatter;
	import com.ithaca.visu.model.Session;
	import com.ithaca.visu.model.User;
	import com.ithaca.visu.model.vo.UserVO;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import spark.components.Button;
	import spark.components.List;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.events.IndexChangeEvent;
	import spark.events.TextOperationEvent;
	
	
	public class UserManagement extends SkinnableComponent
	{
		protected static var log:ILogger = Log.getLogger("views.UserManagement");
		
		[SkinPart("true")]
		public var filter:UserFilters;
		
		[SkinPart("true")]
		public var addUserButton:Button;
		
		[SkinPart("true")]
		public var usersList:List;
		
		[SkinPart("false")]
		public var searchDisplay:AdvancedTextInput;
		
		[SkinPart("true")]
		public var userDetail:UserDetail;
		
		[Bindable] public var selectedUser:User;
		[Bindable] public var filterProfileMax:int = -1;
		[Bindable] public var filterProfileMin:int = -1;
		[Bindable] public var sessions:Session;
		
		public function UserManagement()
		{
			super();
		}
		
		public var userCollection:ArrayCollection;
		private var _users:Array = [];
		
		[Bindable("update")]
		public function get users():Array {return _users;}
		public function set users(value:Array):void
		{
			log.debug("set users " + value);
			if( value != _users )
			{
				_users = value;
				userCollection = new ArrayCollection( _users);
				userCollection.filterFunction = userFilterFunction;
				
				usersList.dataProvider = userCollection;
				dispatchEvent( new Event("update") );
			}
		} 
		
		//_____________________________________________________________________
		//
		// Overriden Methods
		//
		//_____________________________________________________________________
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName,instance);
			if (instance == usersList)
			{
				usersList.addEventListener(IndexChangeEvent.CHANGE, userList_indexChangeHandler);
			}
			if (instance == filter)
			{
				filter.addEventListener(UserFilterEvent.VIEW_ALL,filter_viewAllHandler);
				filter.addEventListener(UserFilterEvent.VIEW_PROFILE,filter_viewProfileHandler);
				filter.addEventListener(UserFilterEvent.VIEW_UNGROUP,filter_viewUngroupHandler);
			}
			if (instance == searchDisplay)
			{
				searchDisplay.addEventListener(TextOperationEvent.CHANGE,searchDisplay_changeHandler);
				searchDisplay.addEventListener(FlexEvent.VALUE_COMMIT,searchDisplay_mxchangeHandler);
			}
			if (instance == addUserButton)
			{
				addUserButton.addEventListener(MouseEvent.CLICK, addButton_clickHandler);
			}
		}
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName,instance);
			if (instance == usersList)
			{
				usersList.removeEventListener(IndexChangeEvent.CHANGE, userList_indexChangeHandler);
			}
			if (instance == filter)
			{
				filter.removeEventListener(UserFilterEvent.VIEW_ALL,filter_viewAllHandler);
				filter.removeEventListener(UserFilterEvent.VIEW_PROFILE,filter_viewProfileHandler);
				filter.removeEventListener(UserFilterEvent.VIEW_UNGROUP,filter_viewUngroupHandler);
			}
			if (instance == searchDisplay)
			{
				searchDisplay.removeEventListener(TextOperationEvent.CHANGE,searchDisplay_changeHandler);
			}
			if (instance == addUserButton)
			{
				addUserButton.removeEventListener(MouseEvent.CLICK, addButton_clickHandler);
			}

			 
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			 
		}
		
		override protected function getCurrentSkinState():String
		{
			return !enabled ? "disabled" : "normal"; 
		}
		
		//_____________________________________________________________________
		//
		// Event Handlers
		//
		//_____________________________________________________________________
		
		/**
		 * @private
		 */
		protected function addButton_clickHandler(event:MouseEvent):void
		{
			usersList.selectedIndex = -1;
			
			userDetail.editing = true;
			userDetail.user = new User( new UserVO());
		}
		
		/**
		 * @private
		 */
		protected function userList_indexChangeHandler(event:IndexChangeEvent):void
		{
			userDetail.user = User(usersList.dataProvider.getItemAt(event.newIndex));
		}
		
		protected function filter_viewAllHandler(event:UserFilterEvent):void
		{
			log.debug("filter change : view all users");
			filterProfileMax = -1;
			
			userCollection.refresh();
			
		}
		protected function filter_viewProfileHandler(event:UserFilterEvent):void
		{
			log.debug("filter users with profile " + event.profile_max.toString(2) +" - "+ event.profile_min.toString(2) );
			
			filterProfileMax = event.profile_max;
			filterProfileMin = event.profile_min;
			userCollection.refresh();
		}
		protected function filter_viewUngroupHandler(event:UserFilterEvent):void
		{
			log.debug("filter change view ungroup users");
			filterProfileMax = -1;
			
			userCollection.refresh();
		}
		protected function searchDisplay_changeHandler(event:TextOperationEvent):void
		{
			log.debug("searchDisplay change"); 

			userCollection.refresh();
		}
		protected function searchDisplay_mxchangeHandler(event:FlexEvent):void
		{
			log.debug("searchDisplay clear"); 
			
			userCollection.refresh();
		}
		
		
	 
		protected function userFilterFunction(item:Object):Boolean
		{
			var u :User = item as User;
			if (filterProfileMax != -1)
			{
				if (u.role > filterProfileMax || u.role < filterProfileMin) return false;
			}
			
			var dict :String = LemmeFormatter.format( u.lastname + "|" + u.firstname+"|"+u.mail);
				
			if (dict.indexOf( searchDisplay.text ) == -1  )
			{
				return false
			}
			else
			{
				return true;
			}	
		}
		
		//_____________________________________________________________________
		//
		// Methods Handlers
		//
		//_____________________________________________________________________
		
		
	}
}