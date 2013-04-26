package hero;
import org.flixel.FlxPath;
import state.AttackState;

/**
 * ...
 * @author Masadow
 */
class Adventurer extends Character
{
	
	public var treasure : Int;

	public function new(asset : String, state : AttackState) 
	{
		super(asset, state);
		
		treasure = 0;
	}
	
	public override function update()
	{
		super.update();		
		if (health <= 0)
		{
			state.killHero(this);
		}
	}
	
}