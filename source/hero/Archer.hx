package hero;
import state.AttackState;

/**
 * ...
 * @author Masadow
 */
class Archer extends Adventurer
{

	public function new(state : AttackState)
	{
		super("assets/archer.png", state);
		health = 100;
		maxHealth = 100;
	}
	
}