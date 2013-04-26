package hero;
import state.AttackState;

/**
 * ...
 * @author Masadow
 */
class Magician extends Adventurer
{

	public function new(state : AttackState) 
	{
		super("assets/magician.png", state);
		health = 50;
		maxHealth = 50;
	}
	
}