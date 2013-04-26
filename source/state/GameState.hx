package state;

import hero.Adventurer;
import hero.Character;
import map.Map;
import nme.geom.Point;
import org.flixel.FlxG;
import org.flixel.FlxPoint;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxTilemap;
import map.Tile;
import org.flixel.FlxObject;
import org.flixel.system.FlxTile;
import nme.display.Graphics;

/**
 * ...
 * @author Masadow
 */
class GameState extends FlxState
{
	public var map : Map;
	public var tilemap : FlxTilemap;
	public var infoPanel : InfoPanel;
	public var entrance : FlxPoint;


	public var constructionState : ConstructionState;
	public var attackState : AttackState;

	override public function create():Void
	{
		#if !neko
		FlxG.bgColor = 0xff131c1b;
		#else
		FlxG.camera.bgColor = {rgb: 0x131c1b, a: 0xff};
		#end
		#if !FLX_NO_MOUSE
		FlxG.mouse.show();
		#end

		map = new Map();

		entrance = new FlxPoint(map.entrance.x + 16, map.entrance.y + 16);

		tilemap = new FlxTilemap();
		add(tilemap);
		tilemap.loadMap(map.twoString(), "assets/maptiles.png", 32, 32, 0, 0, 0);

		//Set collisions on tiles
		tilemap.setTileProperties(Tile.GROUND, FlxObject.NONE);
		tilemap.setTileProperties(Tile.TRAP_HOLE, FlxObject.NONE, holeTrigger);
		tilemap.setTileProperties(Tile.TRAP_HOLE_DAMAGED, FlxObject.ANY);
		tilemap.setTileProperties(Tile.CHEST, FlxObject.NONE, chestTrigger);
		tilemap.setTileProperties(Tile.WALL, FlxObject.WALL);
		tilemap.setTileProperties(Tile.TRAP_BOULDER_TRIGGER, FlxObject.NONE, boulderTrigger);

		infoPanel = new InfoPanel(this);
		add(infoPanel);

		constructionState = new ConstructionState(tilemap, this);
		attackState = new AttackState(tilemap, this);
		add(constructionState);
		FlxG.playMusic("construction.mp3");
	}

	//An object is colliding if 1/2 of its surface is on the tile
	private function isColliding(tile : FlxTile, obj : FlxObject) : Bool
	{
		tile.x = (tile.mapIndex % tilemap.widthInTiles) * 32;
		tile.y = Math.floor(tile.mapIndex / tilemap.widthInTiles) * 32;
		var X = obj.x - tile.x;
		var Y = obj.y - tile.y;
		var propX = X < 0 ? X + 32 : 32 - X;
		var propY = Y < 0 ? Y + 32 : 32 - Y;
		if (propX > 16 && propY > 16)
			return true;
		return false;
	}
	
	public function holeTrigger(tileobj : FlxObject, obj : FlxObject) : Void
	{
		var tile = cast(tileobj, FlxTile);
		if (!isColliding(tile, obj))
			return ;
		if (Std.is(obj, Adventurer))
		{ //If an adventurer take a treasure, then the tile is replaced by a ground tile and the adventurer go back with treasure
			//Change tile by ground
			tilemap.setTileByIndex(tile.mapIndex, Tile.TRAP_HOLE_DAMAGED);
			var hero : Adventurer = cast(obj, Adventurer);
			hero.state.killHero(hero);
		}
	}
	
	public function boulderTrigger(tileobj : FlxObject, obj : FlxObject) : Void
	{
		var tile = cast(tileobj, FlxTile);
		if (!isColliding(tile, obj))
			return ;
		if (Std.is(obj, Adventurer))
		{ // If an adventurer trigger the boulder
			if (constructionState.trigger[tile.mapIndex] != null)
			{
				var hero : Adventurer = cast(obj, Adventurer);
				hero.state.throwBoulder(constructionState.trigger[tile.mapIndex]);
			}
		}
	}

	public function chestTrigger(tileobj : FlxObject, obj : FlxObject) : Void
	{
		var tile = cast(tileobj, FlxTile);
		if (!isColliding(tile, obj))
			return ;
		if (Std.is(obj, Adventurer))
		{ //If an adventurer take a treasure, then the tile is replaced by a ground tile and the adventurer go back with treasure
			//Change tile by ground
			tilemap.setTileByIndex(tile.mapIndex, Tile.GROUND);
			infoPanel.activeTreasure--;
			var hero : Adventurer = cast(obj, Adventurer);
			//Give the treasure
			hero.treasure++;
			//Calculate new path
			var path = tilemap.findPath(hero.getMidpoint(), entrance);
			if (path != null)
				hero.followPath(path);
		}
	}
	
	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update():Void
	{
		super.update();		
	}

	override public function draw():Void
	{
		super.draw();
	}
	
	public function switchState() : Void
	{
		if (this.members.remove(constructionState))
		{
			FlxG.playMusic("attack.mp3");
			add(attackState);
			attackState.beginState();
			infoPanel.enableAttack(false);
		}
		else
		{
			FlxG.playMusic("construction.mp3");
			//When we're back to construction set, we gain a level
			infoPanel.currentLevel++;
			attackState.endState();
			remove(attackState);
			add(constructionState);
			infoPanel.enableAttack(true);
		}
	}
	
}
