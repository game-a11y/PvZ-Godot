extends Node
#class_name SoundManager

enum Bus {MASTER, BGM, SFX} 

@onready var sfx: Node = $SFX
@onready var bgm_play: AudioStreamPlayer = $BGMPlay

func _ready() -> void:
	Global.load_config()
	Global.save_config()
	
	
	
#region 播放音乐和音效
func play_bgm(stream: AudioStream):
	bgm_play.stream = stream
	bgm_play.play()

func play_sfx(name:String):
	var player := sfx.get_node(name) as AudioStreamPlayer

	if not player:
		return
		
	# 如果音效正在播放，则跳过
	if player.playing:
		return
		
	player.play()
#endregion

#region 按钮信号连接辅助函数
## 更新开始菜单的UI音效
func setup_ui_start_menu_sound(node:Node, is_menu_button:=false):
	if node is BaseButton:
		var button := node
		button.mouse_entered.connect(play_sfx.bind("StartMenu/ButtonMouseEntered"))
		
		if is_menu_button:
			button.button_down.connect(play_sfx.bind("StartMenu/MenuButtonDown"))
		else:
			if not button.button_down.is_connected(play_sfx):
				button.button_down.connect(play_sfx.bind("StartMenu/OtherButtonDown"))

				
	for child in node.get_children():
		## 如果是Menu或者其上面的节点为Menu
		if child.name == "Menu" or is_menu_button:
			setup_ui_start_menu_sound(child, true)
		else:
			setup_ui_start_menu_sound(child, false)


## 更新主游戏按钮的UI音效
func setup_ui_main_game_sound(node:Node):
	if node is BaseButton:
		if node is CheckButton:
			node.pressed.connect(play_sfx.bind("MainGameUI/CheckButton"))
		else:
			node.button_down.connect(play_sfx.bind("MainGameUI/ButtonDown"))
			
			if node.name == "Return":
				node.pressed.connect(play_sfx.bind("MainGameUI/CheckButton"))
		
		
	for child in node.get_children():
		setup_ui_main_game_sound(child)
#endregion

#region 音量大小调整
func get_volum(bus_index:int):
	var db := AudioServer.get_bus_volume_db(bus_index)
	
	return db_to_linear(db)
	
func set_volume(bus_index:int, v:float) ->void:
	var db := linear_to_db(v)
	AudioServer.set_bus_volume_db(bus_index, db)

#endregion
