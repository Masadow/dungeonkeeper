package map;
import nme.geom.Point;
import nme.Vector;
import org.flixel.FlxPoint;

/**
 * ...
 * @author Masadow
 */
class Map
{
	
	public static var width = 16;
	public static var height = 12;
	private var content : Vector<Int>;
	public var entrance : FlxPoint;
		
	public function new() 
	{
		content = new Vector<Int>(width * height, true);
		reset();
	}
	
	public function reset()
	{
		for (y in 0 ... height)
		{
			for (x in 0 ... width)
			{
				if (x == 0 || x == width - 1
					|| y == 0 || y == height - 1)
					setTile(x, y, Tile.WALL);
				else
					setTile(x, y, Tile.GROUND);
			}
		}
		
		
		if (Std.random(2) == 1)
			entrance = new FlxPoint(0, Std.random(height - 2) + 1);
		else
			entrance = new FlxPoint(Std.random(width - 2) + 1, 0);

		setTile(cast(entrance.x, Int), cast(entrance.y, Int), Tile.ENTRANCE);
		entrance.x *= 32;
		entrance.y *= 32;

		setTile(Std.random(width - 2) + 1, Std.random(height - 2) + 1, Tile.CHEST);

	}
	
	public inline function getTile(x : Int, y : Int) : Int
	{
		return content[x + y * width];
	}
	
	public inline function setTile(x : Int, y : Int, data : Int) : Void
	{
		content[x + y * width] = data;
	}
	
	public function twoString():String {
		var s:String =  "";
		
		for (y in 0 ... height) {
			for (x in 0 ... width)
			{
				if (x > 0)
					s += ",";
				s += getTile(x, y);
			}
			s += "\n";
		}

		return s;
	}
}