package aze.display;

import aze.display.TileLayer;
import aze.display.TileGroup;
import aze.display.TileSprite;
import flash.display.DisplayObject;
import flash.display.Sprite;

/**
 * Tiles container for TileLayer
 * - can contain types compatible with TileSprite or TileGroup
 * - only offers x/y position offset to its content
 * @author Philippe / http://philippe.elsass.me
 */
class TileGroup extends TileBase
{
	public var children:Array<TileBase>;
	#if flash
	var container:Sprite;
	#end
	
	public var lastHeight:Float;
	public var lastWidth:Float;

	public function new(layer:TileLayer)
	{
		super(layer);
		children = new Array<TileBase>();
		#if flash
		container = new Sprite();
		#end
		
		lastHeight = -1;
		lastWidth = -1;
	}

	override public function init(layer:TileLayer):Void
	{
		this.layer = layer;
		if (children != null) initChildren();
	}

	#if flash
	override public function getView():DisplayObject { return container; }
	#end

	inline function initChild(item:TileBase)
	{
		item.parent = this;
		if (layer != null) 
			item.init(layer);
	}

	function initChildren()
	{
		for(child in children)
			initChild(child);
	}

	public inline function indexOf(item:TileBase):Int
	{
		return Lambda.indexOf(children, item);
	}

	public function addChild(item:TileBase):Int
	{
		lastHeight = -1;
		lastWidth = -1;
		
		removeChild(item);
		#if flash
		container.addChild(item.getView());
		#end
		initChild(item);
		return children.push(item);
	}

	public function addChildAt(item:TileBase, index:Int):Int
	{
		lastHeight = -1;
		lastWidth = -1;
		
		removeChild(item);
		#if flash
		container.addChildAt(item.getView(), index);
		#end
		initChild(item);
		children.insert(index, item);
		return index;
	}

	public function removeChild(item:TileBase):TileBase
	{
		lastHeight = -1;
		lastWidth = -1;
		
		if (item.parent == null) return item;
		if (item.parent != this) {
			trace("Invalid parent");
			return item;
		}
		var index = indexOf(item);
		if (index >= 0) 
		{
			#if flash
			container.removeChild(item.getView());
			#end
			children.splice(index, 1);
			item.parent = null;
		}
		return item;
	}

	public function removeChildAt(index:Int):TileBase
	{
		lastHeight = -1;
		lastWidth = -1;
		
		#if flash
		container.removeChildAt(index);
		#end
		var child = children.splice(index, 1)[0];
		if (child != null) child.parent = null;
		return child;
	}

	public function removeAllChildren():Array<TileBase>
	{
		lastHeight = -1;
		lastWidth = -1;
		
		#if flash
		while (container.numChildren > 0) container.removeChildAt(0);
		#end
		for (child in children)
			child.parent = null;
		return children.splice(0, children.length);
	}

	public function getChildIndex(item:TileBase):Int
	{
		return indexOf(item);
	}
	
	public function setChildIndex(item:TileBase, index:Int) 
	{
		lastHeight = -1;
		lastWidth = -1;
		
		var oldIndex = indexOf(item);
		if (oldIndex >= 0 && index != oldIndex) 
		{
			#if flash
			container.setChildIndex(item.getView(), index);
			#end
			children.splice(oldIndex, 1);
			children.insert(index, item);
		}
	}

	public inline function iterator() { return children.iterator(); }

	public var numChildren(get_numChildren, null):Int;
	inline function get_numChildren() { return children != null ? children.length : 0; }

	public var height(get_height, null):Float; // TOFIX incorrect with sub groups
	public function get_height():Float 
	{
		if (numChildren == 0) return 0;
		var ymin = 9999.0, ymax = -9999.0;
		if (lastHeight == -1) {
			for(child in children)
				if (Std.is(child, TileSprite)) {
					var sprite:TileSprite = cast child;
					var h = sprite.height;
					var top = sprite.y - h/2;
					var bottom = top + h;
					if (top < ymin) ymin = top;
					if (bottom > ymax) ymax = bottom;
				}
			lastHeight = ymax - ymin;
		}
		
		return lastHeight;
	}
	
	public var width(get_width, null):Float; // TOFIX incorrect with sub groups
	public function get_width():Float 
	{
		if (numChildren == 0) return 0;
		
		if (lastWidth == -1) {
			var xmin = 9999.0, xmax = -9999.0;
			for(child in children)
				if (Std.is(child, TileSprite)) {
					var sprite:TileSprite = cast child;
					var w = sprite.width;
					var left = sprite.x - w/2;
					var right = left + w;
					if (left < xmin) xmin = left;
					if (right > xmax) xmax = right;
				}
			lastWidth = xmax - xmin;
		}
		return lastWidth;
	}
}