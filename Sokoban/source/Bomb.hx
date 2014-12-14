package ;

import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class Bomb extends FlxSprite
{

	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y);
		loadGraphic("assets/images/bombicon.png", false, 16, 16);
		setSize(8, 14);
		offset.set(4, 2);
		width = 8;
		height = 8;
	}
	
	override public function kill():Void 
	{
		alive = false;
		//FlxTween.tween(this, { alpha:0, y:y - 16 }, .66, {ease:FlxEase.circOut, complete:finishKill } );
		loadGraphic("assets/images/boom.png", false, 64, 64);
		animation.add("boom", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15], 20, false);
		animation.play("boom", false);
		FlxTween.tween(this, { alpha:0, y:y - 16 }, 1.66, { ease:FlxEase.circOut, complete:finishKill } );			
		if (animation.finished) 
			{
				animation.destroy();
				
				exists = false;
			}
				
	}
	
	private function finishKill(_):Void
	{
		exists = false;
	}
	
	
	
	
}