package ;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.system.FlxSound;
import flixel.ui.FlxButton;
import flixel.util.FlxAngle;
import flixel.util.FlxColor;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxAngle;
import flixel.FlxG;
import flixel.util.FlxDestroyUtil;

class Box extends FlxSprite
{

	public var speed:Float = 100;
	private var _sndStep:FlxSound;
	private var _playstate:Class<PlayState>;
	private var player:Player;
	
	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y);
		
		loadGraphic("assets/images/boks.png", true, 16, 16);
		drag.x = drag.y = 2600;
		setSize(14, 14);
		offset.set(2, 2);
	}
	
	override public function destroy():Void {
	
		_sndStep = FlxDestroyUtil.destroy(_sndStep);
	
	}
	
	private function movement():Void
	{
		var _up:Bool = false;
		var _down:Bool = false;
		var _left:Bool = false;
		var _right:Bool = false;
		var _checker:Bool = false;
		
		_checker = FlxG.collide(PlayState._player, PlayState._grpBox);
		FlxG.collide(PlayState._grpBox, PlayState._mWalls);
		
		if (_up && _down)
			_up = _down = false;
		if (_left && _right)
			_left = _right = false;
		
		if ( _up || _down || _left || _right && _checker)
		{
			var mA:Float = 0;
			if (_up && _checker)
			{
				mA = -90;
				facing = FlxObject.UP;
			}
			else if (_down && _checker)
			{
				mA = 90;
				facing = FlxObject.DOWN;
			}
			else if (_left && _checker)
			{
				mA = 180;
				facing = FlxObject.LEFT;
			}
			else if (_right && _checker)
			{
				mA = 0;
				facing = FlxObject.RIGHT;
			}
			FlxAngle.rotatePoint(speed, 0, 0, 0, mA, velocity);
		}
		if ((velocity.x != 0 || velocity.y != 0)&& touching == FlxObject.NONE)
		{
			_sndStep.play();
		}
	}
	
	override public function update():Void 
	{
		movement();
		super.update();
	}
	
}
