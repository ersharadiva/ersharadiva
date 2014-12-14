package;

import flash.display.Stage;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.addons.weapon.FlxBullet;
import flixel.addons.weapon.FlxWeapon;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.group.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxButton;
import flixel.ui.FlxVirtualPad;
import flixel.util.FlxAngle;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.util.FlxSave;
using flixel.util.FlxSpriteUtil;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	public static var _player:Player;
	public static var _mWalls:FlxTilemap;
	public static var _grpBox:FlxTypedGroup<Box>;
	private var _map:FlxOgmoLoader;
	public static var _grpCoins:FlxTypedGroup<Coin>;
	public static var _grpBombs:FlxTypedGroup<Bomb>;
	public static var _grpEnemies:FlxTypedGroup<Enemy>;
	public static var _targetBox:FlxTypedGroup<TargetBox>;
	public static var _portal:FlxTypedGroup<Portal>;
	private var _hud:HUD;
	private var _money:Int = 0;
	public static var _health:Int = 3;
	private var _state:Class<GameOverState>;
	private var _ending:Bool;
	private var _won:Bool;
	private var _sndCoin:FlxSound;
	private var destroycamera:FlxCamera;
	public var player:Player;
	public var targetbox:TargetBox;
	public static var _save:FlxSave;
	private var _inCombat:Bool = false;
	private var _combatHud:CombatHUD;
	#if mobile
	public static var virtualPad:FlxVirtualPad;
	#end

	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		//_map = new FlxOgmoLoader("assets/data/Level1.oel");
		_save = new FlxSave();
		_save.bind("SokobanLevel");

		super.update();
		_map = new FlxOgmoLoader("assets/data/Level" + Reg.level + ".oel");
		_mWalls = _map.loadTilemap("assets/images/tiles.png", 16, 16, "walls");
		_mWalls.setTileProperties(1, FlxObject.NONE);
		_mWalls.setTileProperties(2, FlxObject.ANY);
		add(_mWalls);
		
		_grpCoins = new FlxTypedGroup<Coin>();
		add(_grpCoins);
		
		_grpBombs = new FlxTypedGroup<Bomb>();
		add(_grpBombs);

		_targetBox = new FlxTypedGroup<TargetBox>();
		add(_targetBox);
		
		_grpEnemies = new FlxTypedGroup<Enemy>();
		add(_grpEnemies);
		
		_portal = new FlxTypedGroup<Portal>();
		add(_portal);

		_grpBox = new FlxTypedGroup<Box>();
		add(_grpBox);		
				
		_player = new Player();
		_map.loadEntities(placeEntities, "entities");
		add(_player);
		
		FlxG.camera.follow(_player, FlxCamera.STYLE_TOPDOWN, null, 1);
		
		_hud = new HUD();
		add(_hud);
		
		//laser = new FlxWeapon("laser", player, FlxBullet, 1);
		//laser.makeImageBullet(10, "assets/p_shoot.png", 12,0,false,0,0,true,true);
		//laser.setBulletDirection(FlxWeapon.BULLET_UP, 200);
		//laser.setBulletSpeed(1000);
		
		#if mobile
		virtualPad = new FlxVirtualPad(FULL, NONE);
		add(virtualPad);
		#end
		
		_sndCoin = FlxG.sound.load("assets/sounds/coin.wav");
		
		super.create();	
		
	}
	
	public function placeEntities(entityName:String, entityData:Xml):Void
	{
		var x:Int = Std.parseInt(entityData.get("x"));
		var y:Int = Std.parseInt(entityData.get("y"));
		if (entityName == "player")
		{
			_player.x = x;
			_player.y = y;
		}
		else if (entityName == "coin")
		{
			_grpCoins.add(new Coin(x + 4, y + 4));			
		}
		else if (entityName == "bomb")
		{
			_grpBombs.add(new Bomb (x + 4 , y + 4));
		}
		else if (entityName == "box")
		{
			_grpBox.add(new Box (x + 4 , y + 4));
		}
		else if (entityName == "targetbox")
		{
			_targetBox.add(new TargetBox (x + 4 , y + 4));
		}		
		else if (entityName == "portal")
		{
			_portal.add(new Portal (x + 4 , y + 4));
		}
		else if (entityName == "enemy")
		{
			_grpEnemies.add(new Enemy(x + 4, y, Std.parseInt(entityData.get("etype"))));
		}
	}
	
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
		_player = FlxDestroyUtil.destroy(_player);
		_mWalls = FlxDestroyUtil.destroy(_mWalls);
		_grpCoins = FlxDestroyUtil.destroy(_grpCoins);
		_hud = FlxDestroyUtil.destroy(_hud);
		_sndCoin = FlxDestroyUtil.destroy(_sndCoin);
		_grpBombs = FlxDestroyUtil.destroy(_grpBombs);
		_grpBox = FlxDestroyUtil.destroy(_grpBox);		
		_targetBox = FlxDestroyUtil.destroy(_targetBox);
		_portal = FlxDestroyUtil.destroy(_portal);
		#if mobile
		virtualPad = FlxDestroyUtil.destroy(virtualPad);
		#end
	}

	/**
	 * Function that is called once every frame.
	 */

	override public function update():Void
	{
		super.update();
		#if mobile
		virtualPad.visible = true;
		#end
		var _pause:Bool = false;
		var _checkeranimation:Bool = false;
		var _checkergate:Bool = false;
		_checkeranimation = FlxG.overlap(PlayState._grpBox, PlayState._targetBox);
		_checkergate = FlxG.overlap(PlayState._player, PlayState._portal);
		_pause = FlxG.keys.anyPressed(["P", "p"]);
		if (!_inCombat)
		{
			FlxG.collide(_player, _mWalls);
			FlxG.collide(_mWalls, _grpBox);
			FlxG.collide(_grpBox, _player);
			FlxG.overlap(_grpBox, _targetBox);
			FlxG.collide(_grpEnemies, _mWalls);
			FlxG.overlap(_player, _grpCoins, playerTouchCoin);	
			FlxG.overlap(_player, _grpBombs, playerTouchBomb);
			FlxG.collide(_player, _grpEnemies, playerTouchEnemy);
			
			if (_health == 0)
			{
				FlxG.camera.fade(FlxColor.BLACK, .66, false);
				FlxG.switchState(new GameOverState());
			}
				
			if (_checkeranimation && _checkergate)
			{
				FlxG.overlap(_player, _portal, fadeCamera);
			}	
				if (_ending)
			{
				return;
			}
		}
		else
		{
			if (!_combatHud.visible)
			{
				_health = _combatHud.playerHealth;
				_hud.updateHUD(_health, _money);
				if (_combatHud.outcome == DEFEAT)
				{
					_ending = true;
					FlxG.camera.fade(FlxColor.BLACK, .66, false);
					FlxG.switchState(new GameOverState());
				}
				else
				{
						if (_combatHud.outcome == VICTORY)
						{
							_combatHud.e.kill();
							if (_combatHud.e.etype == 1)
							{
								_won = true;
								_ending = true;
								FlxG.camera.fade(FlxColor.BLACK, .66, false);
								FlxG.switchState(new GameOverState());
							}
						}
						else
						{
							_combatHud.e.flicker();
						}
						
						_inCombat = false;
						_player.active = true;
						_grpEnemies.active = true;
						#if mobile
						virtualPad.visible = true;
						#end
				}
			}
		}
		if (_pause)
		{
			openSubState(new SubState());
		}
	}	
	
	public function fadeCamera(P:Player, PTL:Portal):Void
	{
		FlxG.camera.fade(FlxColor.BLACK, 0.66, false, changeMap);	
	}
	
	public function changeMap():Void
	{
		//_save.data.level[Reg.level] = Reg.level ++; 	
		Reg.level ++;
		_save.data.level = Reg.level;
		FlxG.switchState(new PlayState());
		_save.flush();
	}
	
	private function playerTouchCoin(P:Player, C:Coin):Void
	{
		if (P.alive && P.exists && C.alive && C.exists)
		{
			_money++;
			_hud.updateHUD(_health, _money);
			C.kill();
			_sndCoin.play(true);
		}
	}
	
	private function playerTouchBomb(P:Player, B:Bomb):Void
	{
		if (P.alive && P.exists && B.alive && B.exists)
		{
			_health --;
			_hud.updateHUD(_health, _money);
			B.kill();
			_sndCoin.play(true);
		}
	}
	
	private function playerTouchEnemy(P:Player, E:Enemy):Void
	{
		if (P.alive && P.exists && E.alive && E.exists && !E.isFlickering())
		{
			openSubState(new CombatHUD(E));
			//startCombat(E);
		}
	}
	
	private function startCombat(E:Enemy):Void
	{
		_inCombat = true;
		_player.active = false;
		_grpEnemies.active = false;
		_combatHud.initCombat(_health, E);
	}
}
