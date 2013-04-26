package hero;
import state.AttackState;

/**
 * ...
 * @author Masadow
 */
class Warrior extends Adventurer
{

	public function new(state : AttackState) 
	{
		super("assets/warrior.png", state);
		health = 200;
		maxHealth = 200;
	}
	
}