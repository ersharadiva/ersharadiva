package ;

import flash.geom.Matrix;
import flash.geom.Point;
import flixel.addons.effects.FlxWaveSprite;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import flash.filters.ColorMatrixFilter;
using flixel.util.FlxSpriteUtil;

class SubState extends FlxSubState
{
	// ** These are the sprites that we will use to show the combat hud interface
	private var _sprBack:FlxSprite;	// this is the background sprite
	private var _alpha:Float = 0;	// we will use this to fade in and out our combat hud
	private var _wait:Bool = true;	// this flag will be set to true when don't want the player to be able to do anything (between turns)

	private var _sprScreen:FlxSprite;
	private var _sprWave:FlxWaveSprite;
	private var _btnResume:FlxButton;
	private var _btnRestart:FlxButton;
	private var _btnMainMenu:FlxButton;
	private var _txtPause:FlxText;
	
	public function new() 
	{
		super();		
		
		_sprScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT);
		_sprWave = new FlxWaveSprite(_sprScreen, WaveMode.ALL, 4, 3, 4);
		add(_sprWave);
		
		// first, create our background. Make a black square, then draw borders onto it in white. Add it to our group.
		_sprBack = new FlxSprite().makeGraphic(190, 140, FlxColor.WHITE);
		_sprBack.drawRect(1, 1, 188, 30, FlxColor.BLACK);
		_sprBack.drawRect(1, 32, 188, 106, FlxColor.BLACK);
		_sprBack.screenCenter(true, true);
		add(_sprBack);
		
		_txtPause = new FlxText(_sprBack.x + 51, _sprBack.y - 0.66, 0, "Paused", 22);
		add(_txtPause);
		
		_btnResume = new FlxButton(_sprBack.x + 54, _sprBack.y + 40, "Resume Game", resumeGame);
		add(_btnResume);
				
		_btnRestart = new FlxButton(_sprBack.x + 54, _btnResume.y + 30, "Restart Level", restartGame);
		add(_btnRestart);
		
		_btnMainMenu = new FlxButton(_sprBack.x + 54, _btnRestart.y + 30, "Main Menu", mainMenu);
		add(_btnMainMenu);

		// like we did in our HUD class, we need to set the scrollFactor on each of our children objects to 0,0. We also set alpha to 0 (so we can fade this in)
		_sprBack.scrollFactor.set();
		_sprScreen.scrollFactor.set();
		_sprWave.scrollFactor.set();
		_btnResume.scrollFactor.set();
		_btnRestart.scrollFactor.set();
		_btnMainMenu.scrollFactor.set();
		_txtPause.scrollFactor.set();
		
		// mark this object as not active and not visible so update and draw don't get called on it until we're ready to show it.
		active = false;
		visible = false;
		CameraStuff();
	}
	
	private function resumeGame():Void
	{
		close();
	}
	
	private function restartGame():Void
	{
		close();
		FlxG.resetState();
	}
	
	private function mainMenu():Void
	{
		close();
		FlxG.switchState(new MenuState());
	}
	
	public function CameraStuff():Void
	{
		#if flash
		_sprScreen.pixels.copyPixels(FlxG.camera.buffer, FlxG.camera.buffer.rect, new Point());
		#else
		_sprScreen.pixels.draw(FlxG.camera.canvas, new Matrix(1, 0, 0, 1, 0, 0));
		#end
		var rc:Float = 1 / 3;
		var gc:Float = 1 / 2;
		var bc:Float = 1 / 6;
		_sprScreen.pixels.applyFilter(_sprScreen.pixels, _sprScreen.pixels.rect, new Point(), new ColorMatrixFilter([rc, gc, bc, 0, 0, rc, gc, bc, 0, 0, rc, gc, bc, 0, 0, 0, 0, 0, 1, 0]));
		_sprScreen.resetFrameBitmapDatas();
		_sprScreen.dirty = true;
		
		// make sure we initialize all of these before we start so nothing looks 'wrong' the second time we get 
		visible = true;	// make our hud visible (so draw gets called on it) - note, it's not active, yet!
		
		FlxTween.num(0, 1, .66, { ease:FlxEase.circOut, complete:finishFadeIn });	// do a numeric tween to fade in our combat hud when the tween is finished, call finishFadeIn
		
	}
	
	/**
	 * When we've finished fading in, we set our hud to active (so it gets updates), and allow the player to interact. We show our pointer, too.
	 */
	private function finishFadeIn(_):Void
	{
		active = true;
		_wait = false;
	}
	
	/**
	 * After we fade our Hud out, we set it to not be active or visible (no update and no draw)
	 */
	override public function update():Void 
	{
		super.update();
	}

	override public function destroy():Void 
	{
		super.destroy();
		
		_sprBack = FlxDestroyUtil.destroy(_sprBack);
	}
}
