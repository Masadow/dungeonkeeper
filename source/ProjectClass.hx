package;

import nme.Lib;
import org.flixel.FlxGame;
import state.GameState;
	
class ProjectClass extends FlxGame
{	
	private static var instance : ProjectClass;
	
	public function new()
	{
		instance = this;
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;
		var ratioX:Float = stageWidth / 640;
		var ratioY:Float = stageHeight / 480;
		var ratio:Float = Math.min(ratioX, ratioY);
		super(Math.ceil(stageWidth / ratio), Math.ceil(stageHeight / ratio), GameState, ratio, 30, 30);
	}
	
	public static function reset()
	{
		instance.resetGame();
	}
}
