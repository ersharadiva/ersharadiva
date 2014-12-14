package ;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class Portal extends FlxSprite
{
	private var targetbox:TargetBox;
	private var playstate:PlayState;
	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y);
		super.update();
		loadGraphic("assets/images/portalsmall.png", false, 16, 16);
		offset.set(4, 2);
		animation.add("portalrotate", [0, 1, 2, 3], 10, true);
		animation.add("portaltransparent", [4], 10, true);
	}
	
	override public function update():Void 
	{
		var _checkeranimation:Bool = false;
		var _checkergate:Bool = false;
		_checkeranimation = FlxG.overlap(PlayState._grpBox, PlayState._targetBox);
		_checkergate = FlxG.overlap(PlayState._player, PlayState._portal);
		super.update();
		if (_checkeranimation)
		{
			animation.play("portalrotate");
			
		}
		else if(!_checkeranimation)
		{
			animation.play("portaltransparent");
			
		}	
	}
}