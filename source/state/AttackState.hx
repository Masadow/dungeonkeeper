package state;
import hero.Archer;
import hero.Character;
import hero.Magician;
import hero.Warrior;
import map.Tile;
import nme.geom.Point;
import objects.Arrow;
import objects.Boulder;
import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxObject;
import org.flixel.FlxPoint;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxTilemap;
import hero.Adventurer;
import org.flixel.FlxTimer;
import nme.display.Graphics;

/**
 * ...
 * @author Masadow
 */
class AttackState extends FlxState
{
	
	var tilemap : FlxTilemap;
	var game : GameState;
	
	var remainingHeroes : Int;
	var activeHeroes : Array<Adventurer>;
	
	var arrow : FlxTimer;
	var arrows : FlxGroup;
	
	var boulders : Array<Bool>;
	var bouldersObjects : FlxGroup;

	public function new(tilemap : FlxTilemap, game : GameState)
	{
		super();
		this.tilemap = tilemap;
		this.game = game;
		create();
	}

	override public function create():Void
	{
		super.create();
		
		activeHeroes = new Array<Adventurer>();
		add((arrows = new FlxGroup()));
		add((bouldersObjects = new FlxGroup()));
		boulders = new Array<Bool>();
	}
	
	override public function destroy():Void
	{
		super.destroy();
	}

	public function beginState() : Void
	{
		remainingHeroes = Math.ceil((game.infoPanel.activeTreasure * (Std.random(5) + 1)) / 2);
		
		arrow = new FlxTimer();
		arrow.start(1, 1, activeArrowTrap);
		
		//reload boulder traps
		var bouldersIdx = tilemap.getTileInstances(Tile.TRAP_HOLE_BOULDER);
		if (bouldersIdx != null)
			for (idx in bouldersIdx)
				boulders[idx] = true;
	}
	
	public function endState() : Void
	{
		arrow.stop();
		arrows.clear();
		bouldersObjects.clear();
	}
	
	private function createRandomAdventurer() : Adventurer
	{
		var herotype = Std.random(3);
		if (herotype == 0) 			return new Warrior(this);
		else if (herotype == 1) 	return new Archer(this);
		return new Magician(this);
	}
	
	public function killHero(hero : Adventurer)
	{
		var earnings : Int = 500 * hero.treasure + Std.random(400) + 100;
		game.infoPanel.gold += earnings;
		game.infoPanel.goldCumul += earnings;
		game.infoPanel.heroKilled++;		
		activeHeroes.remove(hero);
		remove(hero);
		FlxG.play("death.mp3");
	}
	
	public function throwBoulder(boulderIdx : Int)
	{
		if (boulders[boulderIdx])
		{ //If a boulder is still available
			FlxG.play("trigger.mp3");

			//Release a rock
			var r = new Boulder((boulderIdx % tilemap.widthInTiles) * 32, Math.floor(boulderIdx / tilemap.widthInTiles) * 32 + 32);
			r.allowCollisions = FlxObject.WALL;
			bouldersObjects.add(r);
			
			//Make the boulder trap empty
			boulders[boulderIdx] = false;
		}
	}

	public function checkBoulders()
	{
		if (bouldersObjects.length > 0)
			for (b in bouldersObjects.members)
				if (b != null)
				{
					var boulder : Boulder = cast(b, Boulder);
					var delete : Bool = false;
					for (hero in activeHeroes)
					{
						if (hero.overlaps(boulder))
						{
							hero.health -= 100;
							delete = true;
							break ;
						}
					}
					if (delete || boulder.overlaps(tilemap) || boulder.y > tilemap.height)
						bouldersObjects.remove(b);
				}
	}
	
	override public function update():Void
	{
		super.update();
		
		checkArrows();
		checkBoulders();
		
		//Retrieve treasures position
		var treasures = game.tilemap.getTileCoords(Tile.CHEST);

		//Actually limit to one hero at a time
		if (remainingHeroes > 0 && activeHeroes.length == 0 && treasures != null)
		{
			var hero : Adventurer = createRandomAdventurer();
			hero.x = game.entrance.x - 16;
			hero.y = game.entrance.y - 16;
			activeHeroes.push(hero);
			add(hero);
			remainingHeroes--;
		}
		else if ((remainingHeroes == 0 || treasures == null) && activeHeroes.length == 0)
		{
			game.switchState();
			return ;
		}

		//Loop through active heroes to make them move
		for (hero in activeHeroes)
		{
			if (hero.pathSpeed == 0 && treasures != null)
			{
				//Get a random treasure position
				var treasure = treasures[Std.random(treasures.length)];
				//Actually, heroes know where chest are
				var path = game.tilemap.findPath(hero.getMidpoint(), treasure);
				if (path != null)
					hero.followPath(path);
			}
			else
				tilemap.overlaps(hero);
			if ((hero.treasure > 0 || treasures == null) && hero.overlapsPoint(game.entrance))
			{ // If the hero has the treasure or if there is no more treasure, then we check if he is at entrance make him go out
				game.infoPanel.lostTreasure += hero.treasure;
				remove(hero);
				activeHeroes.remove(hero);
			}
		}
	}

	public function activeArrowTrap(t : FlxTimer)
	{
		arrow.start(1, 1, activeArrowTrap);
		
		var traps = tilemap.getTileCoords(Tile.TRAP_ARROW);
		
		var playsound = false;

		if (traps != null)
		{
			for (trap in traps)
			{
				//create a new arrow
				var a = new Arrow(trap.x, trap.y);
				a.allowCollisions = FlxObject.WALL;
				arrows.add(a);
				playsound = true;
			}
		}
		
		if (playsound)
			FlxG.play("arrow_throw.mp3");
	}
	
	public function checkArrows()
	{
		if (arrows.length > 0)
			for (a in arrows.members)
				if (a != null)
				{
					var arrow : Arrow = cast(a, Arrow);
					var delete : Bool = false;
					for (hero in activeHeroes)
					{
						if (hero.overlaps(arrow))
						{
							hero.health -= 20;
							delete = true;
							break ;
						}
					}
					tilemap.setTileProperties(Tile.TRAP_HOLE_DAMAGED, FlxObject.NONE);
					if (delete || arrow.overlaps(tilemap) || arrow.y > tilemap.height)
						arrows.remove(a);
					tilemap.setTileProperties(Tile.TRAP_HOLE_DAMAGED, FlxObject.ANY);
				}
	}
	
}
