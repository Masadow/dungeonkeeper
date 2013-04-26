package objects;
import org.flixel.FlxSprite;

/**
 * ...
 * @author Masadow
 */
class Arrow extends FlxSprite
{

	public function new(x : Float, y : Float) 
	{
		super();
		loadGraphic("assets/arrow.png", false, false, 32, 32);
		
		this.x = x - 16;
		this.y = y + 16;
		this.moves = true;
		this.velocity.y = 200;
	}
}