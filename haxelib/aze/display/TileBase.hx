package aze.display;

import flash.display.DisplayObject;

/**
 * @private base tile type
 */

class TileBase
{
	public var layer:TileLayer;
	public var parent:TileGroup;
	
	public var _x:Float;
	public var _y:Float;
	public var x(get_x, set_x):Float;
	public var y(get_y, set_y):Float;
	
	public var animated:Bool;
	public var visible:Bool;
	
	public function get_x():Float {
		return _x;
	}
	
	public function set_x(x:Float):Float {
		_x = x;
		return _x;
	}
	
	public function get_y():Float {
		return _y;
	}
	
	public function set_y(y:Float):Float {
		_y = y;
		return _y;
	}

	function new(layer:TileLayer)
	{
		this.layer = layer;
		x = y = 0.0;
		visible = true;
	}

	function init(layer:TileLayer):Void
	{
		this.layer = layer;
	}

	public function step(elapsed:Int)
	{
	}

	#if flash
	function getView():DisplayObject { return null; }
	#end
}
