extends Node2D
class_name MainGameManager


#region 游戏管理器
@onready var manager: Node2D = $Manager
@onready var hand_manager: HandManager = $Manager/HandManager
@onready var zombie_manager: ZombieManager = $Manager/ZombieManager
@onready var card_manager: CardManager = $Camera2D/CardManager
#endregion


#region UI元素、相机
@onready var ui_remind_word: UIRemindWord = $UIRemindWord
@onready var camera_2d: MainGameCamera = $Camera2D

#endregion

#region 游戏主元素
@onready var background: Sprite2D = $Background
@onready var plant_cells: Node2D = $PlantCells
@onready var temporary_plants: Node2D = $TemporaryPlants
@onready var zombies: Node2D = $Zombies
@onready var temporary_zombies: Node2D = $TemporaryZombies
@onready var bullets: Node2D = $Bullets
@onready var day_suns: DaySuns = $DaySuns
#endregion

#region bgm
@export var bgm_choose_card: AudioStream
@export var bgm_main_game: AudioStream
#endregion

#region 设置
@export_group("游戏设置")
## 柱子模式
@export var mode_column := true
#endregion

#region 主游戏运行阶段
enum MainGameProgress{
	NONE,			## 无
	CHOOSE_CARD,	## 选卡界面
	MAIN_GAME,		## 游戏阶段
	GAME_OVER		## 游戏结束阶段
}

var main_game_progress:MainGameProgress
#endregion

#region 游戏参数
@export_group("本局游戏参数")
#region 出怪参数
@export_subgroup("出怪参数")
## 游戏出怪波次，每10波生成1旗帜
@export var max_wave := 30

## **统一的僵尸种类刷新列表**，这将定义整局游戏每波可以刷新的僵尸种类
@export var zombie_refresh_types : Array[Global.ZombieType] = [
	Global.ZombieType.ZombieNorm,       # 普通僵尸
	#Global.ZombieType.ZombieFlag,       # 旗帜僵尸
	Global.ZombieType.ZombieCone,       # 路障僵尸
	Global.ZombieType.ZombiePoleVaulter, # 撑杆僵尸
	Global.ZombieType.ZombieBucket,      # 铁桶僵尸
	Global.ZombieType.ZombiePaper      # 读报僵尸
	
]
#endregion

#region 卡片参数
## 当前已有的植物卡片在Global文件中
@export_subgroup("卡片参数")
## 最大卡槽数量
@export_range(1,10) var max_choosed_card_num :int = 10

#endregion

#region 关卡参数
## 当前已有的植物卡片在Global文件中
@export_subgroup("关卡参数")

## 关卡背景
@export var game_bg := Global.GameBg.FrontDay
## 夜晚初始生成的墓碑数量
@export var init_tombstone_num := 5


#endregion

#endregion

@export_group("是否为测试场景")
@export var is_test := false




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	## 初始化僵尸管理器
	zombie_manager.init_zombie_manager(zombies, max_wave)
	## 初始化植物种植区域
	hand_manager.init_plant_cells()
	## 初始化游戏，游戏背景
	_init_main_game()
	## 主游戏进程
	main_game_progress = MainGameProgress.CHOOSE_CARD
	
	if not is_test:
		SoundManager.play_bgm(bgm_choose_card)
		## 初始化待选卡槽
		card_manager.init_CardChooser()
		## 初始化选择卡槽
		card_manager.init_card_bar()
		## 初始化展示僵尸
		zombie_manager.show_zombie_create()
		
		await get_tree().create_timer(1.0).timeout
		await start_game_move_camera()
		card_manager.move_card_bar(true)
		card_manager.move_card_chooser(true)
	
	else:
		main_game_progress = MainGameProgress.MAIN_GAME
		
		SoundManager.play_bgm(bgm_main_game)
		## 测试场景初始化植物卡片
		card_manager.test_scenes_init_cards()
		## 设置信号连接
		hand_manager.card_game_signal_connect(card_manager.cards, card_manager.shovel_bg)

# 初始化游戏，游戏背景
func _init_main_game():
	var texture: Texture2D = Global.GameBgTextureMap.get(game_bg, null)
	if texture:
		background.texture = texture
	else:
		push_error("未找到背景贴图，枚举值: %d" % game_bg)
	
	if game_bg == Global.GameBg.FrontNight:
		## 加载墓碑场景
		hand_manager.init_tombstone_scenes()


## 选择卡片完成后开始游戏
func cheeosed_card_start_game():
		## 主游戏进程阶段
		main_game_progress = MainGameProgress.MAIN_GAME
		## 隐藏多余卡槽
		card_manager.judge_disappear_add_card_bar() 
		## 断开原本的卡片信号连接
		card_manager.card_disconnect_card()

		## 隐藏待选卡槽
		await card_manager.move_card_chooser(false)

		## 相机移动回游戏场景
		await camera_2d.move_to(Vector2(0, 0), 2)
		## 删除展示僵尸
		zombie_manager.show_zombie_delete()
		## 等待一秒后显示“准备安放植物动画提醒”
		
		if game_bg == Global.GameBg.FrontNight:
			#创建墓碑
			hand_manager.create_tombstone(init_tombstone_num)
		
		await get_tree().create_timer(1.0).timeout
		await ui_remind_word.ready_set_plant()
		## 红字结束，可以种植,连接卡片和铲子种植信号
		hand_manager.card_game_signal_connect(card_manager.cards, card_manager.shovel_bg)

		await get_tree().create_timer(1.0).timeout
		
		SoundManager.play_bgm(bgm_main_game)
		
		if game_bg != Global.GameBg.FrontNight:
			# 开始天降阳光
			day_suns.start_day_sun()
			
		# 10秒后开始刷新僵尸		
		await get_tree().create_timer(10).timeout
		zombie_manager.start_first_wave()
		zombie_manager.flag_progress_bar.visible = true
	

func start_game_move_camera():
	# 移动相机查看僵尸
	await camera_2d.move_to(Vector2(390, 0), 2)
	
## 显示植物血量
func display_plant_HP_label():
	hand_manager.display_plant_HP_label()
