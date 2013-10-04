package aze.display;

import flash.display.BitmapData;
import openfl.display.Tilesheet;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Point;

using StringTools;

typedef TileDef = {
	name : String,
	size : Rectangle,
	?bitmap : BitmapData,
	?center : Point
}


/**
 * A cross-targets Tilesheet container, with animation and trimming support
 *
 * - animations are matched by name (startsWith) and cached after 1st request,
 * - rect: marks the actual pixel content of the spritesheet that should be displayed for a sprite,
 * - size: original (before trimming) sprite dimensions are indicated by the size's (width,height); 
 *         rect offset inside the original sprite is indicated by size's (left,top).
 *
 * @author Philippe / http://philippe.elsass.me
 */
class TilesheetEx extends Tilesheet
{
	public var scale:Float;
	var tileDefs : Array<TileDef>;

	#if haxe3
		var anims:Map<String,Array<Int>>;
	#else
		var anims:Hash<Array<Int>>;
	#end

	#if flash
	var bmps:Array<BitmapData>;
	#end

	public function new(img:BitmapData, textureScale:Float = 1.0)
	{
		super(img);

		scale = 1/textureScale;
		
		tileDefs = new Array<TileDef>();

		#if haxe3
			anims = new Map<String, Array<Int>>();
		#else
			anims = new Hash<Array<Int>>();
		#end

	}

	#if flash
	public function addDefinition(name:String, size:Rectangle, bmp:BitmapData)
	{
		tileDefs.push({name : name, size : size, bitmap : bmp});
	}
	#else
	public function addDefinition(name:String, size:Rectangle, rect:Rectangle, center:Point)
	{
		tileDefs.push({name : name, size : size, center : center});
		addTileRect(rect, center);
	}
	#end

	public function getAnim(name:String):Array<Int>
	{
		if (anims.exists(name))
			return anims.get(name);
		var indices = new Array<Int>();
		for (i in 0...tileDefs.length)
		{
			if (tileDefs[i].name.startsWith(name)) 
				indices.push(i);
		}
		anims.set(name, indices);
		return indices;
	}

	public function getDefinition(name : String) : TileDef {
		var indexes = getAnim(name);
		if (indexes.length > 0) {
			return tileDefs[indexes[0]];	
		}
		return null;
	}

	inline public function getSize(indice:Int):Rectangle
	{
		if (indice < tileDefs.length) return tileDefs[indice].size;
		else return new Rectangle();
	}

	#if flash
	inline public function getBitmap(indice:Int):BitmapData
	{
		return tileDefs[indice].bitmap;
	}
	#end

	static public function createFromAssets(fileNames:Array<String>, padding:Int=0, spacing:Int=0)
	{
		var names:Array<String> = [];
		var images:Array<BitmapData> = [];
		for(fileName in fileNames)
		{
			var name = fileName.split("/").pop();
			var image = openfl.Assets.getBitmapData(fileName);
			names.push(name);
			images.push(image);
		}
		return createFromImages(names, images, padding, spacing);
	}

	static public function createFromImages(names:Array<String>, images:Array<BitmapData>, padding:Int=0, spacing:Int=0)
	{
		var width = 0;
		var height = padding;
		for(image in images)
		{
			if (image.width + padding*2 > width) width = image.width + padding*2;
			height += image.height + spacing;
		}
		height -= spacing;
		height += padding;

		var img = new BitmapData(closestPow2(width), closestPow2(height), true, 0);
		var sheet = new TilesheetEx(img);

		var pos = new Point(padding, padding);
		for(i in 0...images.length)
		{
			var image = images[i];
			img.copyPixels(image, image.rect, pos, null, null, true);
			#if flash
			sheet.addDefinition(names[i], image.rect, image);
			#else
			var rect = new Rectangle(padding, pos.y, image.width, image.height);
			var center = new Point(image.width/2, image.height/2);
			sheet.addDefinition(names[i], image.rect, rect, center);
			#end
			pos.y += image.height + spacing;
		}
		return sheet;
	}

	static public function closestPow2(v:Int)
	{
		var p = 2;
		while (p < v) p = p << 1;
		return p;
	}
}
