package hero;
import org.flixel.FlxGroup;
import org.flixel.FlxSprite;
import state.AttackState;
import org.flixel.FlxG;
import nme.display.Graphics;

/**
 * ...
 * @author Masadow
 */
class Character extends FlxSprite
{

	public var state : AttackState;
	private var maxHealth : Int;
	
	public function new(asset : String, state : AttackState)
	{
		super();
		
		this.state = state;
		
		loadGraphic(asset, true, false, 32, 32);
		
		addAnimation("default", [1], 5);
		addAnimation("bottom", [0, 2], 5);
		addAnimation("top", [3, 5], 5);
		addAnimation("right", [6, 8], 5);
		addAnimation("left", [9, 11], 5);
		
		play("default");
	}

	public override function update():Void
	{
		super.update();
		if (pathSpeed > 0)
		{
			if (pathAngle > 45 && pathAngle <= 135)
				play("right");
			else if (pathAngle > 135 && pathAngle >= -135)
				play("bottom");
			else if (pathAngle < -45 && pathAngle > -135)
				play("left");
			else
				play("top");
		}
		else
			play("default");
	}
	
	#if flash
	public override function calcFrame()
	{
		super.calcFrame();
	#else
	public override function calcFrame(AreYouSure:Bool = false)
	{
		super.calcFrame(AreYouSure);
	#end
		//Draw health bars
		var gfx:Graphics = FlxG.flashGfx;
		gfx.clear();
		gfx.moveTo(0, 5);
		gfx.lineStyle(3, 0x00FF00);
		gfx.lineTo(frameWidth * (health / maxHealth), 5);
		framePixels.draw(FlxG.flashGfxSprite);
	}
}