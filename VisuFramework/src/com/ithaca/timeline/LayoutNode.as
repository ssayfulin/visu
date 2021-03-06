package com.ithaca.timeline
{
	import mx.collections.ArrayCollection;
	import spark.components.SkinnableContainer;
	import mx.events.CollectionEvent;
	
	public class LayoutNode extends SkinnableContainer
	{
		private var _layout 		: XML ;	
		public  var titleComponent 	: SkinnableContainer;	
		public  var _timeline		: Timeline;
		public  var parentNode		: LayoutNode;
		
		public function set layoutXML ( value : XML ) : void { _layout = value; }
		public function get layoutXML ( ) : XML	{ return _layout;	} 

		public function addChildAndTitle ( child : LayoutNode, index : int = -1 ) : void 
		{ 	
			child.parentNode = this;
		//	if ( !(child is LayoutModifier))
			{
				if ( index < 0 || index >= numElements)
					addElement( child );
				else
					addElementAt( child, index );
				
				if ( titleComponent && child.titleComponent)
				{
					if ( index < 0 || index >= numElements)
						titleComponent.addElement( child.titleComponent );
					else					
						titleComponent.addElementAt( child.titleComponent, index );				
				}
			}
		}
		
		public function getTraceLineGroup() : TraceLineGroup
		{
			var nodeCursor : LayoutNode = this;
			
			while ( nodeCursor && !(nodeCursor is TraceLineGroup) )
				nodeCursor = nodeCursor.parentNode;
			
			if (nodeCursor)			
				return (nodeCursor as TraceLineGroup);
			else
				return null;
		}
		
		public function getElementByName( name : String) : LayoutNode
		{
			for ( var childIndex : uint = 0; childIndex < this.numElements; childIndex++ )
			{
				var child : LayoutNode = this.getElementAt( childIndex ) as LayoutNode;
				if ( child is TraceLine  && (child as TraceLine).title == name )
					return child;

				var recursiveChild : LayoutNode= child.getElementByName( name );
				if ( recursiveChild != null )
					return recursiveChild;
			}
			return null;
		}
		
		public function removeChildAndTitle( child : LayoutNode ) : void
		{
			removeElement( child  );
			titleComponent.removeElement( child.titleComponent );			
		}	
		
		public function onSourceChange( event : CollectionEvent ) : void { };
		public function resetObselCollection ( obselsCollection : ArrayCollection = null) : void { };
	}
}