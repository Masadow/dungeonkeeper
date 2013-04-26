package palette;
import org.flixel.FlxSprite;
import nme.geom.Point;
import org.flixel.FlxText;
import org.flixel.FlxTilemap;
import map.Tile;

/**
 * ...
 * @author Masadow
 */
class Brush
{
	
	public var tile : Int;
	public var index : Point;
	public var sprite : FlxSprite;
	public var title : FlxText;
	public var description: FlxText;
	public var price: FlxText;
	public var priceInt : Int;

	public function new(tiles : FlxTilemap, index : Point) 
	{
		this.tile = tiles.getTile(cast(index.x, Int), cast(index.y, Int));
		this.index = index;
		sprite = tiles.tileToFlxSprite(cast(index.x, Int), cast(index.y, Int), tile);
		title = new FlxText(0, 0, 200, Tile.tiles[tile].title, 11);
		description = new FlxText(0, 0, 200, Tile.tiles[tile].description, 11);
		price = new FlxText(0, 0, 200, "Price: " + (Tile.tiles[tile].price == 0 ? "FREE!" : "" + Tile.tiles[tile].price), 11);
		priceInt = Tile.tiles[tile].price;
	}
	
}