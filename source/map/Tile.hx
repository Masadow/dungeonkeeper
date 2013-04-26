package map;
import org.flixel.FlxGroup;
import org.flixel.FlxButton;
import state.ConstructionState;

/**
 * ...
 * @author Masadow
 */
class Tile
{

	public static var WALL = 0;
	public static var GROUND = 1;
	public static var CHEST = 2;
	public static var ENTRANCE = 1;
	public static var TRAP_HOLE = 3;
	public static var TRAP_HOLE_DAMAGED = 4;
	public static var TRAP_BOULDER = 5;
	public static var TRAP_HOLE_BOULDER = 6;
	public static var TRAP_ARROW = 7;
	public static var SELECTION_SQUARE = 8;
	public static var TRAP_BOULDER_TRIGGER = 9;
	
	public static var tiles : Array<Tile> = initTileInfo();

	public var type : Int;
	public var title : String;
	public var description : String;
	public var price : Int;
	public var group : FlxGroup;
	
	//buttons
	private var sell : FlxButton;
	private var repair : FlxButton;
	private var trigger : FlxButton;

	public static function initTileInfo() : Array<Tile>
	{
		var ret = new Array<Tile>();
		
		ret[WALL] = new Tile(WALL, "Wall", "Nobody can pass through walls", 0);
		ret[GROUND] = new Tile(GROUND, "Ground", "Let's have a walk !", 0);
		ret[CHEST] = new Tile(CHEST, "Treasure", "More you have, more adventurers will come!", 500);
		ret[TRAP_HOLE] = new Tile(TRAP_HOLE, "Hole trap", "Instant kill ! But it costs you 50 gold in reparation each time it kills someone", 200);
		ret[TRAP_HOLE_DAMAGED] = new Tile(TRAP_HOLE_DAMAGED, "Hole trap damaged", "50 gold to turn into a hole trap", 200);
		ret[TRAP_HOLE_BOULDER] = new Tile(TRAP_HOLE_BOULDER, "Boulder", "A big boulder will roll and break some bones, mouahahahahahah", 100);
		ret[TRAP_ARROW] = new Tile(TRAP_ARROW, "Arrows", "A pretty well hidden trap which continuously throw deadly arrows", 300);
		ret[TRAP_BOULDER_TRIGGER] = new Tile(TRAP_BOULDER_TRIGGER, "Trigger", "A trigger to release boulder from boulder hole", 50);

		return ret;
	}
	
	public function new(?type : Int, ?title : String, ?description : String, ?price : Int)
	{
		this.type = type;
		this.title = title;
		this.description = description;
		this.price = price;
		this.group = new FlxGroup();
	}
	
	public function bindGroup(state : ConstructionState)
	{
		sell = new MyButton(525, 170, "Sell (" + (price / 2) + "g)", state.sellSelection);
		group.add(sell);
		if (type == TRAP_HOLE_DAMAGED)
		{
			repair = new MyButton(525, 200, "Repair (50g)", state.repairSelection);
			group.add(repair);
		}
		else if (type == TRAP_HOLE_BOULDER)
		{
			trigger = new MyButton(525, 200, "Trigger (50g)", state.addTrigger);
			group.add(trigger);
		}
	}
	
}