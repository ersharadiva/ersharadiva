package ;

import flixel.addons.effects.FlxTrail;
import flixel.addons.weapon.FlxBullet;
import flixel.addons.weapon.FlxWeapon;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxAngle;
import flixel.util.FlxColor;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxAngle;
import flixel.FlxG;
import flixel.util.FlxDestroyUtil;

class Player extends FlxSprite
{

	public var speed:Float = 70;
	private var _sndStep:FlxSound;
	public static inline var BULLET_UP:Int = -90;
	public static inline var BULLET_DOWN:Int = 90;
	public static inline var BULLET_LEFT:Int = 180;
	public static inline var BULLET_RIGHT:Int = 0;
	private var _weapondefiner:FlxWeapon;
	private var _trail:FlxTrail;
	
	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y);
		
		loadGraphic("assets/images/player.png", true, 16, 16);
		animation.add("d", [0, 1, 2, 1, 0], 6, false);
		animation.add("l", [3, 4, 5, 4, 3], 6, false);
		animation.add("u", [6, 7, 8, 7, 6], 6, false);
		animation.add("r", [11, 10, 9, 10, 11], 6, false);
		drag.x = drag.y = 1600;
		setSize(8, 14);
		offset.set(4, 2);
		_sndStep = FlxG.sound.load("assets/sounds/step.wav");
		_weapondefiner = new FlxWeapon("pistol", PlayState._player, FlxBullet, 1);
		_weapondefiner.makeImageBullet(10, "assets/images/p_shoot.png", 12,0,false,0,0,true,true);
		//_weapondefiner.setBulletDirection(FlxWeapon.BULLET_RIGHT, 200);
		_weapondefiner.setBulletSpeed(1000);
		FlxG.state.add(_weapondefiner.group);
	}
	
	private function movement():Void
	{
		var _up:Bool = false;
		var _down:Bool = false;
		var _left:Bool = false;
		var _right:Bool = false;
		var _reset:Bool = false;
		var _checkerwalls:Bool = false;
		var _checkerbox:Bool = false;
		var _pause:Bool = false;
		var _firepressed:Bool = false;
		_checkerwalls = FlxG.collide(PlayState._player, PlayState._mWalls);
		_checkerbox = FlxG.collide(PlayState._player, PlayState._grpBox);
		
		#if !FLX_NO_KEYBOARD
		_up = FlxG.keys.anyPressed(["UP", "W"]);
		_down = FlxG.keys.anyPressed(["DOWN", "S"]);
		_left = FlxG.keys.anyPressed(["LEFT", "A"]);
		_right = FlxG.keys.anyPressed(["RIGHT", "D"]);
		_reset = FlxG.keys.anyPressed(["R", "r"]);
		_pause = FlxG.keys.anyPressed(["P", "p"]);
		_firepressed = FlxG.keys.anyJustPressed(["N", "n"]);
		#end
		
		#if mobile
		_up = _up || PlayState.virtualPad.buttonUp.status == FlxButton.PRESSED;
		_down = _down || PlayState.virtualPad.buttonDown.status == FlxButton.PRESSED;
		_left  = _left || PlayState.virtualPad.buttonLeft.status == FlxButton.PRESSED;
		_right = _right || PlayState.virtualPad.buttonRight.status == FlxButton.PRESSED;
		#end
		
		if (_reset)
		{
			FlxG.resetState();
		}	
		
		if (_up && _down)
			_up = _down = false;
		if (_left && _right)
			_left = _right = false;
		
		if ( _up || _down || _left || _right)
		{
			var mA:Float = 0;
			if (_up)
			{
				mA = -90;
				facing = FlxObject.UP;
				if (_firepressed)
				{
					_weapondefiner.setBulletDirection(FlxWeapon.BULLET_UP, 200);
					_weapondefiner.fire;	
				}
			}
			else if (_down)
			{
				mA = 90;
				facing = FlxObject.DOWN;
				if (_firepressed)
				{
					_weapondefiner.setBulletDirection(FlxWeapon.BULLET_DOWN, 200);
					_weapondefiner.fire;	
				}
			}
			else if (_left)
			{
				mA = 180;
				facing = FlxObject.LEFT;
				if (_firepressed)
				{
					_weapondefiner.setBulletDirection(FlxWeapon.BULLET_LEFT, 200);
					_weapondefiner.fire;	
				}
			}
			else if (_right)
			{
				mA = 0;
				facing = FlxObject.RIGHT;
				if (_firepressed)
				{
					_weapondefiner.setBulletDirection(FlxWeapon.BULLET_RIGHT, 200);
					_weapondefiner.fire;	
				}
			}
			FlxAngle.rotatePoint(speed, 0, 0, 0, mA, velocity);
		}
	}
	
	override public function update():Void 
	{
		movement();
		super.update();
		if ((velocity.x != 0 || velocity.y != 0)&& touching == FlxObject.NONE)
		{
			_sndStep.play();
			switch(facing)
			{
				case FlxObject.LEFT:
					animation.play("l");
				case FlxObject.RIGHT:
					animation.play("r");
				case FlxObject.UP:
					animation.play("u");
				case FlxObject.DOWN:
					animation.play("d");
			}
		}
	}
		
	override public function destroy():Void 
	{	
		_sndStep = FlxDestroyUtil.destroy(_sndStep);
	}
}
