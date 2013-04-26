package objects;
import org.flixel.FlxSprite;

/**
 * ...
 * @author Masadow
 */
class Boulder extends FlxSprite
{

	public function new(x : Int, y : Int)
	{
		super();
		loadGraphic("assets/boulder.png", false, false, 32, 32);
		
		this.x = x;
		this.y = y;
		this.moves = true;
		this.velocity.y = 120;
		
		this.addAnimation("roll", [0, 1, 2, 3]);
		this.play("roll");
	}
	
}