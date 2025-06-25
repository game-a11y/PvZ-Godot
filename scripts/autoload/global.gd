extends Node

#func _ready() -> void:
	#load_game()

#region 游戏相关

# 图层顺序：
#世界背景： 0
#Ui1: 100	鼠标未移入UI时，在最下面
#墓碑: 150
#植物： 200
#僵尸： 400
#小推车： 450
#子弹： 600
#爆炸： 650
#阳光： 800
#Ui2 : 900 鼠标移入UI时，在植物和僵尸下面
#真实铲子 : 950
#血量显示： 980
#UI3： 1000 进度条、准备放置植物
#UI4： 1100 所有备选植物卡槽
#UI5:  1150 卡片选择移动时临时位置
#奖杯： 2000



#region 角色
# 定义枚举
enum CharacterType {Plant, Zombie}

#region 卡片
enum CardInfoAttribute {
	CoolTime,
	SunCost,	
}

var CardInfo = {
	PlantType.PeaShooterSingle: {
		CardInfoAttribute.CoolTime: 2.0,
		CardInfoAttribute.SunCost: 100
		},
	PlantType.SunFlower: {
		CardInfoAttribute.CoolTime: 2.0,
		CardInfoAttribute.SunCost: 50
		},
	PlantType.CherryBomb: {
		CardInfoAttribute.CoolTime: 2.0,
		CardInfoAttribute.SunCost: 150
		},
	PlantType.WallNut: {
		CardInfoAttribute.CoolTime: 2.0,
		CardInfoAttribute.SunCost: 50
		},
	PlantType.PotatoMine: {
		CardInfoAttribute.CoolTime: 2.0,
		CardInfoAttribute.SunCost: 25
		},
	PlantType.SnowPea: {
		CardInfoAttribute.CoolTime: 2.0,
		CardInfoAttribute.SunCost: 175
		},
	PlantType.Chomper: {
		CardInfoAttribute.CoolTime: 2.0,
		CardInfoAttribute.SunCost: 150
		},
	PlantType.PeaShooterDouble: {
		CardInfoAttribute.CoolTime: 2.0,
		CardInfoAttribute.SunCost: 200
		},
	PlantType.PuffShroom: {
		CardInfoAttribute.CoolTime: 2.0,
		CardInfoAttribute.SunCost: 0
		},
	PlantType.SunShroom: {
		CardInfoAttribute.CoolTime: 2.0,
		CardInfoAttribute.SunCost: 25
		},
	PlantType.FumeShroom: {
		CardInfoAttribute.CoolTime: 0.0,
		CardInfoAttribute.SunCost: 75
		},
	PlantType.GraveBuster: {
		CardInfoAttribute.CoolTime: 2.0,
		CardInfoAttribute.SunCost: 75
		},
	PlantType.HypnoShroom: {
		CardInfoAttribute.CoolTime: 2.0,
		CardInfoAttribute.SunCost: 75
		},
	PlantType.ScaredyShroom: {
		CardInfoAttribute.CoolTime: 2.0,
		CardInfoAttribute.SunCost: 25
		},
	PlantType.IceShroom: {
		CardInfoAttribute.CoolTime: 2.0,
		CardInfoAttribute.SunCost: 75
		},
	PlantType.DoomShroom: {
		CardInfoAttribute.CoolTime: 2.0,
		CardInfoAttribute.SunCost: 125
		},
}


#endregion

#region 植物
enum PlantType {
	PeaShooterSingle, 
	SunFlower, 
	CherryBomb,
	WallNut,
	PotatoMine,
	SnowPea,
	Chomper,
	PeaShooterDouble,
	PuffShroom,
	SunShroom,
	FumeShroom,
	GraveBuster,
	HypnoShroom,
	ScaredyShroom,
	IceShroom,
	DoomShroom,
	}

var PlantTypeSceneMap = {
	PlantType.PeaShooterSingle: preload("res://scenes/character/plant/001_pea_shooter_single.tscn"),
	PlantType.SunFlower: preload("res://scenes/character/plant/002_sun_flower.tscn"),
	PlantType.CherryBomb: preload("res://scenes/character/plant/003_cherry_bomb.tscn"),
	PlantType.WallNut: preload("res://scenes/character/plant/004_wall_nut.tscn"),
	PlantType.PotatoMine: preload("res://scenes/character/plant/005_potato_mine.tscn"),
	PlantType.SnowPea: preload("res://scenes/character/plant/006_snow_pea.tscn"),
	PlantType.Chomper: preload("res://scenes/character/plant/007_chomper.tscn"),
	PlantType.PeaShooterDouble: preload("res://scenes/character/plant/008_pea_shooter_double.tscn"),
	PlantType.PuffShroom: preload("res://scenes/character/plant/009_puff_shroom.tscn"),
	PlantType.SunShroom: preload("res://scenes/character/plant/010_sun_shroom.tscn"),
	PlantType.FumeShroom: preload("res://scenes/character/plant/011_fume_shroom.tscn"),
	PlantType.GraveBuster: preload("res://scenes/character/plant/012_grave_buster.tscn"),
	PlantType.HypnoShroom: preload("res://scenes/character/plant/013_hypno_shroom.tscn"),
	PlantType.ScaredyShroom: preload("res://scenes/character/plant/014_scaredy_shroom.tscn"),
	PlantType.IceShroom: preload("res://scenes/character/plant/015_ice_shroom.tscn"),
	PlantType.DoomShroom: preload("res://scenes/character/plant/016_doom_shroom.tscn"),
}

var StaticPlantTypeSceneMap = {
	PlantType.PeaShooterSingle: preload("res://scenes/character/plant/001_pea_shooter_single_static.tscn"),
	PlantType.SunFlower: preload("res://scenes/character/plant/002_sun_flower_static.tscn"),
	PlantType.CherryBomb: preload("res://scenes/character/plant/003_cherry_bomb_static.tscn"),
	PlantType.WallNut: preload("res://scenes/character/plant/004_wall_nut_static.tscn"),
	PlantType.PotatoMine: preload("res://scenes/character/plant/005_potato_mine_static.tscn"),
	PlantType.SnowPea: preload("res://scenes/character/plant/006_snow_pea_static.tscn"),
	PlantType.Chomper: preload("res://scenes/character/plant/007_chomper_static.tscn"),
	PlantType.PeaShooterDouble: preload("res://scenes/character/plant/008_pea_shooter_double_static.tscn"),
	PlantType.PuffShroom: preload("res://scenes/character/plant/009_puff_shroom_static.tscn"),
	PlantType.SunShroom: preload("res://scenes/character/plant/010_sun_shroom_static.tscn"),
	PlantType.FumeShroom: preload("res://scenes/character/plant/011_fume_shroom_static.tscn"),
	PlantType.GraveBuster: preload("res://scenes/character/plant/012_grave_buster_static.tscn"),
	PlantType.HypnoShroom: preload("res://scenes/character/plant/013_hypno_shroom_static.tscn"),
	PlantType.ScaredyShroom: preload("res://scenes/character/plant/014_scaredy_shroom_static.tscn"),
	PlantType.IceShroom: preload("res://scenes/character/plant/015_ice_shroom_static.tscn"),
	PlantType.DoomShroom: preload("res://scenes/character/plant/016_doom_shroom_static.tscn"),
}

#endregion

#region 僵尸
enum ZombieType {
	ZombieNorm, 
	ZombieFlag, 
	ZombieCone, 
	ZombiePoleVaulter,
	ZombieBucket,
	ZombiePaper
	}

var ZombieTypeSceneMap = {
	ZombieType.ZombieNorm: preload("res://scenes/character/zombie/001_zombie_norm.tscn"),
	ZombieType.ZombieFlag: preload("res://scenes/character/zombie/002_zombie_flag.tscn"),
	ZombieType.ZombieCone: preload("res://scenes/character/zombie/003_zombie_cone.tscn"),
	ZombieType.ZombiePoleVaulter: preload("res://scenes/character/zombie/004_zombie_pole_vaulter.tscn"),
	ZombieType.ZombieBucket: preload("res://scenes/character/zombie/005_zombie_bucket.tscn"),
	ZombieType.ZombiePaper: preload("res://scenes/character/zombie/006_zombie_paper.tscn"),
}
#endregion

#endregion

#region 子弹种类
## 普通，穿透，真实
enum BulletMode {
	Norm, 			# 按顺序对二类防具、一类防具、本体造成伤害
	penetration, 	# 对二类防具造成伤害同时对一类防具造成伤害
	real			# 不对二类防具造成伤害，直接对一类防具造成伤害
	} 

#endregion

#region 游戏背景
enum GameBg{
	FrontDay,
	FrontNight
}

var GameBgTextureMap = {
	GameBg.FrontDay: preload("res://assets/image/background/background1.jpg"),
	GameBg.FrontNight: preload("res://assets/image/background/background2.jpg"),
	#GameBg.BackNight: preload("res://assets/bg_back_night.png"),
}

#endregion

#endregion

#region 用户相关


#region 用户配置相关
const CONGIF_PATH := "user://config.ini"

## 用户选项控制台
var auto_collect_sun := false
var auto_collect_coin := false
var disappear_spare_card_Placeholder := false
var display_plant_HP_label := false
var display_zombie_HP_label := false

var time_scale := 1.0

func save_config():
	var config := ConfigFile.new()
	## 音乐相关
	config.set_value("audio", "master", SoundManager.get_volum(SoundManager.Bus.MASTER)) 
	config.set_value("audio", "bgm", SoundManager.get_volum(SoundManager.Bus.BGM)) 
	config.set_value("audio", "sfx", SoundManager.get_volum(SoundManager.Bus.SFX)) 
	# 用户选项控制台相关
	config.set_value("user_control", "auto_collect_sun", auto_collect_sun) 
	config.set_value("user_control", "auto_collect_coin", auto_collect_coin) 
	config.set_value("user_control", "disappear_spare_card_Placeholder", disappear_spare_card_Placeholder) 
	config.set_value("user_control", "display_plant_HP_label", display_plant_HP_label) 
	config.set_value("user_control", "display_zombie_HP_label", display_zombie_HP_label) 

	config.save(CONGIF_PATH)
	
func load_config():
	var config := ConfigFile.new()
	config.load(CONGIF_PATH)
	
	SoundManager.set_volume(
		SoundManager.Bus.MASTER,
		config.get_value("audio", "master", 1)
	)
	
	SoundManager.set_volume(
		SoundManager.Bus.BGM,
		config.get_value("audio", "bgm", 0.5)
	)
	
	SoundManager.set_volume(
		SoundManager.Bus.SFX,
		config.get_value("audio", "sfx", 0.5)
	)
	
	auto_collect_sun = config.get_value("user_control", "auto_collect_sun", false) 
	auto_collect_coin = config.get_value("user_control", "auto_collect_coin", false) 
	disappear_spare_card_Placeholder = config.get_value("user_control", "disappear_spare_card_Placeholder", false) 
	display_plant_HP_label = config.get_value("user_control", "display_plant_HP_label", false) 
	display_zombie_HP_label = config.get_value("user_control", "display_zombie_HP_label", false) 
	
	
	
#endregion

#region 用户游戏存档相关
const SAVE_GAME_PATH = "user://SaveGame.save"

var curr_plant = [
	PlantType.PeaShooterSingle,
	PlantType.SunFlower, 
	PlantType.CherryBomb,
	PlantType.WallNut,
	PlantType.PotatoMine,
	PlantType.SnowPea,
	PlantType.Chomper,
	PlantType.PeaShooterDouble,
	PlantType.PuffShroom,
	PlantType.SunShroom,
	PlantType.FumeShroom,
	PlantType.GraveBuster,
	PlantType.HypnoShroom,
	PlantType.ScaredyShroom,
	PlantType.IceShroom,
	PlantType.DoomShroom,
]



var card_in_seed_chooser = preload("res://scenes/ui/card_in_seed_chooser.tscn")


func save_game():
	var save_file = FileAccess.open(SAVE_GAME_PATH, FileAccess.WRITE)
	var data:Dictionary = {
		"curr_plnat" : curr_plant
	}
	var json_string = JSON.stringify(data)

	save_file.store_line(json_string)

func load_game():
	if not FileAccess.file_exists(SAVE_GAME_PATH):
		curr_plant = []
		return # Error! We don't have a save to load.
	
	# 打开文件
	var save_file = FileAccess.open(SAVE_GAME_PATH, FileAccess.READ)
	# 读取全部内容
	while save_file.get_position() < save_file.get_length():
		var data = JSON.parse_string(save_file.get_line())
		# 加载数据
		curr_plant = data["curr_plnat"]
	
	return
	
#endregion


#endregion

#region 关卡相关
enum MainGameLevel{
	FrontDay,
	FrontNight
}

var  MainGameLevelBgmMap = {
	MainGameLevel.FrontDay: "res://assets/audio/BGM/front_day.mp3",
	MainGameLevel.FrontNight: "res://assets/audio/BGM/front_night.mp3"
}

var main_game_level :MainGameLevel = MainGameLevel.FrontNight


## 预加载关卡
enum MainScenes{
	StartMenu,
	ChooseLevel,
	MainGame
}

var MainScenesMap = {
	MainScenes.StartMenu: "res://scenes/main/01StartMenu.tscn",
	MainScenes.ChooseLevel: "res://scenes/main/02ChooesLevel.tscn",
	MainScenes.MainGame: "res://scenes/main/MainGame.tscn",
}


#endregion
