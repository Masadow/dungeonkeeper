package ;
import org.flixel.FlxButton;
import org.flixel.FlxGroup;
import org.flixel.FlxSave;
import org.flixel.FlxText;
import org.flixel.FlxTilemap;
import state.ConstructionState;
import state.GameState;
import org.flixel.FlxG;
import org.flixel.FlxPoint;

/**
 * ...
 * @author Masadow
 */
class InfoPanel extends FlxGroup
{	
	// Gold
	public var gold(getGold, setGold) : Int;
	private var goldTxt : FlxText;
	private function getGold() : Int { return gold; }
	private function setGold(gold : Int) : Int
	{
		this.gold = gold;
		goldTxt.text = "Gold: " + gold;
		return this.gold;
	}

	// GoldCumul
	public var goldCumul(getGoldCumul, setGoldCumul) : Int;
	private var goldCumulTxt : FlxText;
	private function getGoldCumul() : Int { return goldCumul; }
	private function setGoldCumul(goldCumul : Int) : Int
	{
		this.goldCumul = goldCumul;
		goldCumulTxt.text = "Total gold earned: " + goldCumul;
		return this.goldCumul;
	}

	// activeTreasure
	public var activeTreasure(getactiveTreasure, setactiveTreasure) : Int;
	private var activeTreasureTxt : FlxText;
	private function getactiveTreasure() : Int { return activeTreasure; }
	private function setactiveTreasure(activeTreasure : Int) : Int
	{
		this.activeTreasure = activeTreasure;
		activeTreasureTxt.text = "Active treasures: " + activeTreasure;
		return this.activeTreasure;
	}

	// lostTreasure
	public var lostTreasure(getlostTreasure, setlostTreasure) : Int;
	private var lostTreasureTxt : FlxText;
	private function getlostTreasure() : Int { return lostTreasure; }
	private function setlostTreasure(lostTreasure : Int) : Int
	{
		this.lostTreasure = lostTreasure;
		lostTreasureTxt.text = "Lost treasures: " + lostTreasure;
		return this.lostTreasure;
	}

	// currentLevel
	public var currentLevel(getcurrentLevel, setcurrentLevel) : Int;
	private var currentLevelTxt : FlxText;
	private function getcurrentLevel() : Int { return currentLevel; }
	private function setcurrentLevel(currentLevel : Int) : Int
	{
		this.currentLevel = currentLevel;
		currentLevelTxt.text = "Current level: " + currentLevel;
		return this.currentLevel;
	}

	// heroKilled
	public var heroKilled(getheroKilled, setheroKilled) : Int;
	private var heroKilledTxt : FlxText;
	private function getheroKilled() : Int { return heroKilled; }
	private function setheroKilled(heroKilled : Int) : Int
	{
		this.heroKilled = heroKilled;
		heroKilledTxt.text = "Heroes killed: " + heroKilled;
		return this.heroKilled;
	}
	
	private var reset : FlxButton;
	private var save : FlxButton;
	private var load : FlxButton;
	private var attack : FlxButton;
	private var game : GameState;

	public function new(game : GameState)
	{
		super();

		this.game = game;
		
		//Graphics
		goldTxt = new FlxText(20, 400, 300, null, 10);
		add(goldTxt);
		goldCumulTxt = new FlxText(20, 430, 300, null, 10);
		add(goldCumulTxt);
		activeTreasureTxt = new FlxText(140, 400, 300, null, 10);
		add(activeTreasureTxt);
		lostTreasureTxt = new FlxText(140, 430, 300, null, 10);
		add(lostTreasureTxt);
		currentLevelTxt = new FlxText(260, 400, 300, null, 10);
		add(currentLevelTxt);
		heroKilledTxt = new FlxText(260, 430, 300, null, 10);
		add(heroKilledTxt);

		//Values
		gold = 1000;
		goldCumul = 0;
		activeTreasure = 1;
		lostTreasure = 0;
		currentLevel = 1;
		heroKilled = 0;

		//Buttons
		attack = new MyButton(380, 400, "Attack!", attackEvent);
		add(attack);
		save = new MyButton(380, 440, "Save", saveEvent);
		add(save);
		load = new MyButton(480, 400, "Load", loadEvent);
		add(load);
		reset = new MyButton(480, 440, "Reset", resetEvent);
		add(reset);
	}
	
	private function resetEvent() : Void
	{
		ProjectClass.reset();
	}

	private function saveEvent() : Void
	{
		var save : FlxSave = new FlxSave();
		
		save.bind("slot1");

		save.data.entrance = new FlxPoint(game.entrance.x, game.entrance.y);
		save.data.tilemap = game.tilemap.getData();
		save.data.infoPanel = game.infoPanel;
		save.data.trigger = game.constructionState.trigger;

		save.close();
	}

	private function loadEvent() : Void
	{
		var save : FlxSave = new FlxSave();
		
		save.bind("slot1");

		for (idx in 0 ... save.data.tilemap.length)
			game.tilemap.setTileByIndex(idx, save.data.tilemap[idx]);
		game.constructionState.trigger = new Array<Null<Int>>();
		for (idx in 0 ... save.data.trigger.length)
			game.constructionState.trigger[idx] = save.data.trigger[idx];
		game.entrance = new FlxPoint(save.data.entrance.x, save.data.entrance.y);
		//game.map = save.data.map;
		game.infoPanel.gold = save.data.infoPanel.gold;
		game.infoPanel.goldCumul = save.data.infoPanel.goldCumul;
		game.infoPanel.activeTreasure = save.data.infoPanel.activeTreasure;
		game.infoPanel.heroKilled = save.data.infoPanel.heroKilled;
		game.infoPanel.lostTreasure = save.data.infoPanel.lostTreasure;
		game.infoPanel.currentLevel = save.data.infoPanel.currentLevel;
		//game.constructionState = save.data.constructionState;
		//game.attackState = save.data.attackState;

		save.close();

	}
	
	private function attackEvent() : Void
	{
		game.switchState();
	}
	
	public function enableAttack(b : Bool) : Void
	{
		attack.active = b;
	}

}