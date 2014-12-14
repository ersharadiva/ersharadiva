package ;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class TargetBox extends FlxSprite
{
	public var playstate:PlayState;
	public var gateopen:Bool = false;
	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y);
		loadGraphic("assets/images/switch1.png", false, 15, 16);
		offset.set(4, 4);
		setSize(4, 4);
		animation.add("pinkpressed", [0, 1, 2, 3], 5, false);
		animation.add("pinknotpressed", [3, 2, 1, 0], 5, false);
		
	}
	
	override public function update():Void 
	{
		var _checkeranimation:Bool = false;
		_checkeranimation = FlxG.overlap(PlayState._grpBox, PlayState._targetBox);
		
		if (_checkeranimation)
		{
			animation.play("pinknotpressed");
			//gateopen = true;
		}
		else if(!_checkeranimation)
		{
			animation.play("pinkpressed");
			gateopen = true;
		}	
	}
}