extends CanvasLayer
class_name ControlCanvasLayer

@onready var card_manager: CardManager = $"../../../../../../Camera2D/CardManager"
@onready var main_game: MainGameManager = $"../../../../../.."

@onready var check_box: CheckBox = $OptionBG/HBoxContainer/VBoxContainer/CheckBox
@onready var check_box_2: CheckBox = $OptionBG/HBoxContainer/VBoxContainer/CheckBox2
@onready var check_box_3: CheckBox = $OptionBG/HBoxContainer/VBoxContainer/CheckBox3
@onready var check_box_4: CheckBox = $OptionBG/HBoxContainer/VBoxContainer/CheckBox4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.load_config()
	check_box.button_pressed = Global.auto_collect_sun
	check_box_2.button_pressed = Global.auto_collect_coin
	check_box_3.button_pressed = Global.disappear_spare_card_Placeholder
	check_box_4.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN


## 自动收集阳光
func _on_check_box_toggled(toggled_on: bool) -> void:
	Global.auto_collect_sun = toggled_on
	
	Global.save_config()

## 隐藏多余卡槽
func _on_check_box_3_toggled(toggled_on: bool) -> void:
	Global.disappear_spare_card_Placeholder = toggled_on
	
	Global.save_config()
	## 游戏阶段时隐藏多余卡片
	if main_game.main_game_progress == main_game.MainGameProgress.MAIN_GAME:
		card_manager.judge_disappear_add_card_bar()


## 游戏全屏
func _on_check_box_4_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_texture_button_pressed() -> void:
	visible = false


func appear_canvas_layer_control() -> void:
	visible = true


func _on_check_box_5_toggled(toggled_on: bool) -> void:
	Global.display_plant_HP_label = toggled_on
	
	Global.save_config()
	main_game.display_plant_HP_label()
	
