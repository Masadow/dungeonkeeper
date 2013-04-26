package state;
import org.flixel.FlxGroup;
import org.flixel.FlxState;
import map.Map;
import map.Tile;
import org.flixel.FlxSprite;
import nme.geom.Point;
import org.flixel.FlxTilemap;
import org.flixel.FlxG;
import palette.Palette;
import org.flixel.FlxObject;

/**
 * ...
 * @author Masadow
 */
class ConstructionState extends FlxState
{

	private var selectionSquare : FlxSprite;
	private var hoverSquare : FlxSprite;
	private var lastPoint : Point;
	private var tilemap : FlxTilemap;
	private var palette : Palette;
	private var game : GameState;
	public var trigger : Array<Null<Int>>;
	
	private var selection : Tile;
	
	public function new(tilemap : FlxTilemap, game : GameState)
	{
		super();
		this.tilemap = tilemap;
		this.game = game;
		create();
		
		//Bind every tile groups
		Tile.tiles[Tile.CHEST].bindGroup(this);
		Tile.tiles[Tile.TRAP_ARROW].bindGroup(this);
		Tile.tiles[Tile.TRAP_HOLE_BOULDER].bindGroup(this);
		Tile.tiles[Tile.TRAP_HOLE].bindGroup(this);
		Tile.tiles[Tile.TRAP_HOLE_DAMAGED].bindGroup(this);
		Tile.tiles[Tile.TRAP_BOULDER_TRIGGER].bindGroup(this);
	}

	override public function create():Void
	{
		lastPoint = new Point( -1, -1);
		
		hoverSquare = new FlxSprite(0, 0, "assets/hover.png");
		selectionSquare = new FlxSprite(0, 0, "assets/selection.png");
		
		palette = new Palette();
		add(palette);
		selection = null;
		
		trigger = new Array<Null<Int>>();
	}

	override public function destroy():Void
	{
		super.destroy();
	}
	
	public function isValidMap()
	{
		tilemap.setTileProperties(Tile.TRAP_HOLE, FlxObject.ANY);
		var chests = tilemap.getTileCoords(Tile.CHEST, true);
		if (chests == null)
			return false;
		else
			for (tile in chests)
				if (tilemap.findPath(game.entrance, tile) == null)
					return false;
		tilemap.setTileProperties(Tile.TRAP_HOLE, FlxObject.NONE, game.holeTrigger);
		return true;
	}
	
	public function clearSelection()
	{
		var ret = remove(selectionSquare);
		if (ret != null)
		{
			remove(selection.group);
			selection = null;
		}
		return ret;
	}
	
	public function repairSelection()
	{
		tilemap.setTile(cast(selectionSquare.x / 32, Int), cast(selectionSquare.y / 32, Int), Tile.TRAP_HOLE);
		game.infoPanel.gold -= 50;
		updateTileInfo(Tile.TRAP_HOLE);
		add(selectionSquare);
	}
	
	public function addTrigger()
	{
		var data = tilemap.getData();
		if (data != null)
		{
			for (tileidx in 0 ... data.length)
			{
				if (data[tileidx] == Tile.GROUND
					&& tileidx > tilemap.widthInTiles && tileidx % tilemap.widthInTiles != 0)
				{
					game.infoPanel.gold -= 50;
					tilemap.setTileByIndex(tileidx, Tile.TRAP_BOULDER_TRIGGER);
					trigger[tileidx] = cast(selectionSquare.x / 32, Int) + tilemap.widthInTiles * cast(selectionSquare.y / 32, Int);
					return ;
				}					
			}
		}
	}
	
	public function sellSelection()
	{
		tilemap.setTile(cast(selectionSquare.x / 32, Int), cast(selectionSquare.y / 32, Int), Tile.GROUND);
		game.infoPanel.gold += cast(selection.price / 2, Int);
		if (selection.type == Tile.CHEST)
			game.infoPanel.activeTreasure--;
		clearSelection();
	}

	public function updateTileInfo(tile : Int)
	{
		clearSelection();
		selection =	Tile.tiles[tile];
		add(selection.group);
		FlxG.play("button.mp3");
	}
	
	override public function update():Void
	{
		super.update();

		//If the mouse is inside the map then hover concerned tile
		var point = new Point(Math.floor(FlxG.mouse.x / 32), Math.floor(FlxG.mouse.y / 32));
		if (point.x > 0 && point.x < Map.width - 1
			&& point.y > 0 && point.y < Map.height - 1)
		{
			if (point != lastPoint)
			{ //If the tile has changed, then update UI
				lastPoint.x = point.x;
				lastPoint.y = point.y;
				remove(hoverSquare);
				hoverSquare.x = point.x * 32;
				hoverSquare.y = point.y * 32;
				add(hoverSquare);
			}
			if (FlxG.mouse.justReleased())
			{//If the tile was clicked
				var clicked = tilemap.getTile(cast(point.x, Int), cast(point.y, Int));
				if (clicked == Tile.GROUND || clicked == Tile.WALL)
				{ //If we clicked on a free square
					if (clearSelection() != null)
					{ // Move a tile
						var x = Math.floor(selectionSquare.x / 32);
						var y = Math.floor(selectionSquare.y / 32);
						tilemap.setTile(cast(point.x, Int), cast(point.y, Int), tilemap.getTile(x, y));
						if (isValidMap())
						{
							var oldidx = x + tilemap.widthInTiles * y;
							var newidx = cast(point.x, Int) + tilemap.widthInTiles * cast(point.y, Int);
							FlxG.play("button.mp3");
							//if it's a trigger, move its trigger data
							if (trigger[oldidx] != null)
							{
								trigger[newidx] = trigger[oldidx];
								trigger[oldidx] = null;
							}
							else if (tilemap.getTileByIndex(oldidx) == Tile.TRAP_HOLE_BOULDER)
							{ //if it's a boulder trap, change its trigger data
								for (i in 0 ... trigger.length)
									if (trigger[i] == oldidx)
										trigger[i] = newidx;
							}
							tilemap.setTile(x, y, Tile.GROUND);
						}
						else
							tilemap.setTile(cast(point.x, Int), cast(point.y, Int), clicked);
					}
					else if (palette.brush != null)
					{ //If a brush is set, then rather than selecting element, we put the new one
						if (game.infoPanel.gold >= palette.brush.priceInt)
						{ //If player has money
							var ok = tilemap.setTile(cast(point.x, Int), cast(point.y, Int), palette.brush.tile);
							//check if it won't block path to any treasure
							if (!(ok = isValidMap()))
								tilemap.setTile(cast(point.x, Int), cast(point.y, Int), clicked);
							if (ok) //pay tile if ok
							{
								game.infoPanel.gold -= palette.brush.priceInt;
								FlxG.play("button.mp3");
								if (palette.brush.tile == Tile.CHEST) // If treasure, then increment active treasure count
									game.infoPanel.activeTreasure++;
							}
						}
					}
				}
				else
				{ //Select tile
					palette.clearBrush();
					selectionSquare.x = point.x * 32;
					selectionSquare.y = point.y * 32;
					updateTileInfo(clicked);
					add(selectionSquare);
				}
			}
		}
		else
		{ //When outside the map, remove hover and if clicked, selection 
			remove(hoverSquare);
			if (FlxG.mouse.justReleased())
				clearSelection();
		}
	}
}