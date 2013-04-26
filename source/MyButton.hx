package ;

import org.flixel.FlxButton;
import org.flixel.FlxSound;

/**
 * ...
 * @author Masadow
 */
class MyButton extends FlxButton
{

	public function new(x :Int, y : Int, label : String, OnClick:Void->Void) 
	{
		super(x, y, label, OnClick);
		
		this.soundUp = new FlxSound();
		this.soundUp.loadEmbedded("button.mp3");
	}
	
}