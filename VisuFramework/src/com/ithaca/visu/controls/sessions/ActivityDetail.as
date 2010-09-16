package com.ithaca.visu.controls.sessions
{
	import com.lyon2.visu.model.Activity;
	import com.lyon2.visu.model.ActivityElement;
	import com.lyon2.visu.model.ActivityElementType;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.collections.IList;
	
	import spark.components.Button;
	import spark.components.DataGroup;
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.RichText;
	import spark.components.TextArea;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.components.supportClasses.TextBase;
	
	

	[SkinState("normal")]
	[SkinState("open")]
	
	public class ActivityDetail extends SkinnableComponent
	{
		
		[SkinPart("true")]
		public var titleDisplay : TextBase;
		
		[SkinPart("true")]
		public var durationDisplay : TextBase;
		
		[SkinPart("true")]
		public var startButton : Button;
		
		[SkinPart("true")]
		public var statementGroup : Group;
				
		[SkinPart("true")]
		public var documentGroup : Group;
		
		[SkinPart("false")]
		public var memoDisplay : Label;
		
		private var open:Boolean;

		private var _activity:Activity; 
		private var activityChanged : Boolean;
		
		private var statementList:IList;
		private var documentList:IList; 
		private var memo:String=""; 
		
		
		public function ActivityDetail()
		{
			super();
			statementList = new ArrayCollection();
			documentList = new ArrayCollection();
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName,instance);
			if (instance == titleDisplay)
			{
				titleDisplay.addEventListener(MouseEvent.CLICK, titleDisplay_clickHandler);
			}
			if (instance == statementGroup)
			{
				trace("add statementGroup");
				if (statementList.length > 0) 
					addStatements(statementList);
			}
			
			if (instance == documentGroup)
			{
				trace("add documentGroup");
				if (documentList.length > 0) 
					addDocuments(documentList);
			}

			if (instance == memoDisplay)
			{
				if (_activity != null) memoDisplay.text = memoDisplay.toolTip = memo;
			}
			 
		}
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName,instance);
			if (instance == titleDisplay)
			{
				titleDisplay.removeEventListener(MouseEvent.CLICK, titleDisplay_clickHandler);
			}
			 
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			if (activityChanged)
			{
				activityChanged = false;
				
				titleDisplay.text = _activity.title;
				durationDisplay.text = _activity.duration.toString();
				parseActivityElements();

			}
		}
		
		override protected function getCurrentSkinState():String
		{
			return !enabled? "disable" : open? "open" : "normal";
		}
		
		protected function parseActivityElements():void
		{
			for each (var el:ActivityElement in _activity.getListActivityElement())
			{
				switch(el.type_element)
				{
					case ActivityElementType.MEMO:
						memo = el.data;				
						break;
					case ActivityElementType.STATEMENT:					
						statementList.addItem(el);
						break;
					case ActivityElementType.DOCUMENT:
						documentList.addItem(el);
						break;
				}
			}
		}
		protected function addStatements(list:IList):void
		{
			for each( var el:ActivityElement in list)
			{
				var s:ActivityElementDetail = new ActivityElementDetail();
				s.percentWidth = 100;
				s.text = el.data;
				statementGroup.addElement(s);
			}
		}
		protected function addDocuments(list:IList):void
		{
			for each( var el:ActivityElement in list)
			{
				var d:Label = new Label();
				d.text = el.data;
				documentGroup.addElement(d);
			}
		}
		
		[Bindable("activityChanged")]
		public function get activity():Activity
		{
			return _activity;
		}
		
		public function set activity(value:Activity):void
		{
			if( _activity == value) return;
			_activity = value;
			activityChanged = true;
			dispatchEvent( new Event("activityChanged"));
			invalidateProperties();
		}
	 	
		protected function titleDisplay_clickHandler(event:MouseEvent):void
		{
			open = !open;
			invalidateSkinState();
		}
		
	}
}