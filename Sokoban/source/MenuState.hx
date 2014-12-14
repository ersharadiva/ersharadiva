package;

import flixel.addons.ui.FlxUISprite;
import flixel.addons.ui.FlxUIState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSave;
import flixel.addons.ui.FlxClickArea;
import flixel.addons.ui.interfaces.IFlxUIState;
using flixel.util.FlxSpriteUtil;

/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends FlxUIState
{
	
	private var _btnContinue:FlxButton;
	private var _btnNewGame:FlxButton;
	private var _txtTitle:FlxText;
	private var _btnOptions:FlxButton;
	private var _txtNotice:FlxText;
	private var playstate:PlayState;
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		var back = new FlxUISprite(0, 0, "assets/gfx/flamesilks.png");
		add(back);

		_txtTitle = new FlxText(20, 0, 0, "Sokoban", 22);

		_txtTitle.alignment = "center";
		_txtTitle.screenCenter(true, false);
		add(_txtTitle);
		
		_btnContinue = new FlxButton(0, 0, "Continue", clickContinue);
		//_btnContinue.loadGraphic("assets/images/play.png", true, 100, 30);
		_btnNewGame = new FlxButton(0, 0, "New Game", clickNewGame);
		_btnNewGame.x = (FlxG.width / 2) - _btnNewGame.width + 40;
		_btnNewGame.y = FlxG.height - _btnNewGame.height - 130;
		_btnNewGame.onUp.sound = FlxG.sound.load("assets/sounds/select.wav");
		add(_btnNewGame);
		
		_btnContinue.x = (FlxG.width / 2) - _btnContinue.width + 40;
		_btnContinue.y = FlxG.height - _btnContinue.height - 100;
		_btnContinue.onUp.sound = FlxG.sound.load("assets/sounds/select.wav");
		add(_btnContinue);		
		
		_btnOptions = new FlxButton(0, 0, "Options", clickOptions);
		_btnOptions.x = (FlxG.width / 2) - _btnContinue.width + 40;
		_btnOptions.y = FlxG.height - _btnOptions.height - 70;
		add(_btnOptions);
		super.create();
	}
	
	private function clickNewGame():Void
	{
		FlxG.switchState(new PlayState());
		Reg.level =  1;
		PlayState._save = new FlxSave();
		PlayState._save.bind("SokobanLevel");
		PlayState._save.data.level = Reg.level;
		PlayState._save.flush();
	}
	
	private function clickContinue():Void
	{
		//Reg.level = PlayState._save.data.level;
		//Reg.level = _savelevel.data.level;
		FlxG.switchState(new PlayState());		
		
	}	

	private function clickOptions():Void
	{
		FlxG.switchState(new OptionsState());
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
		_btnNewGame = FlxDestroyUtil.destroy(_btnNewGame);
		_btnContinue = FlxDestroyUtil.destroy(_btnContinue);
		_txtTitle = FlxDestroyUtil.destroy(_txtTitle);
		_btnOptions = FlxDestroyUtil.destroy(_btnOptions);
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();
	}	
}