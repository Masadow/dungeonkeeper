package palette;
import nme.geom.Point;
import map.Map;
import org.flixel.FlxButton;
import org.flixel.FlxGroup;
import org.flixel.FlxSprite;
import org.flixel.FlxTilemap;
import map.Tile;
import org.flixel.FlxG;

/**
 * ...
 * @author Masadow
 */
class Palette extends FlxGroup
{

	var tiles : FlxTilemap;

	public var brush : Brush;

	private var selectionSquare : FlxSprite;
	private var hoverSquare : FlxSprite;
	private var lastPoint : Point;
	
	private static var x_offset = 525;
	private static var y_offset = 20;

	private var cancel : FlxButton;
	
	public function clearBrush() : Void
	{
		remove(selectionSquare);
		updateBrushInfo(true);
	}
	
	public function new() 
	{
		super();
		
		var mapData = 	[
							[Tile.WALL, Tile.GROUND, Tile.CHEST].join(","),
							[Tile.TRAP_ARROW, Tile.TRAP_HOLE, Tile.TRAP_HOLE_BOULDER].join(',')
						].join("\n");
		tiles = new FlxTilemap();
		tiles.loadMap(mapData, "assets/maptiles.png", 32, 32, 0, 0, 0);
		tiles.x = x_offset;
		tiles.y = y_offset;
		add(tiles);

		hoverSquare = new FlxSprite(0, 0, "assets/hover.png");
		selectionSquare = new FlxSprite(0, 0, "assets/selection.png");
		
		lastPoint = new Point( -1, -1);
		
		cancel = new MyButton(x_offset + 10, y_offset + 70, "Cancel brush", cancel_Event);
		add(cancel);
		
		//no brush
		brush = null;
	}
	
	private function cancel_Event() : Void
	{
		updateBrushInfo(true);
		remove(selectionSquare);
	}

	override public function update():Void
	{
		super.update();

		//If the mouse is inside the map then hover concerned tile
		var point = new Point(Math.floor((FlxG.mouse.x - x_offset) / 32), Math.floor((FlxG.mouse.y - y_offset) / 32));
		if (point.x >= 0 && point.x < 3
			&& point.y >= 0 && point.y < 2)
		{
			if (point != lastPoint)
			{ //If the tile has changed, then update UI
				lastPoint.x = point.x;
				lastPoint.y = point.y;
				remove(hoverSquare);
				hoverSquare.x = point.x * 32 + x_offset;
				hoverSquare.y = point.y * 32 + y_offset;
				add(hoverSquare);
			}
			if (FlxG.mouse.justReleased())
			{//If the tile was clicked
				
				var nPoint = new Point(point.x * 32 + x_offset, point.y * 32 + y_offset);
				updateBrushInfo(true);
				if (remove(selectionSquare) == null || nPoint.x != selectionSquare.x || nPoint.y != selectionSquare.y)
				{
					selectionSquare.x = nPoint.x;
					selectionSquare.y = nPoint.y;
					add(selectionSquare);
					brush = new Brush(tiles, point);
					updateBrushInfo();
					FlxG.play("button.mp3");
				}
			}
		}
		else
		{ //When outside the map, remove hover and if clicked, selection 
			remove(hoverSquare);
		}
	}
	
	private function updateBrushInfo(destroy : Bool = false)
	{
		if (brush == null)
			return ; // Return if item is already destroyed
		remove(brush.sprite);
		remove(brush.title);
		remove(brush.description);
		remove(brush.price);
		if (destroy)
			brush = null;
		else
		{			
			brush.sprite.x = x_offset;
			brush.sprite.y = y_offset + 150;
			add(brush.sprite);
			
			brush.title.x = x_offset + 40;
			brush.title.y = y_offset + 155;
			add(brush.title);

			brush.description.x = x_offset;
			brush.description.y = y_offset + 200;
			add(brush.description);
			
			brush.price.x = x_offset;
			brush.price.y = y_offset + 300;
			add(brush.price);
		}
	}
	
}