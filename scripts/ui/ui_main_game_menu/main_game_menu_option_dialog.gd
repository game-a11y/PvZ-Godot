extends TextureRect
class_name MainGameMenuOptionDialog

@onready var dialog: Dialog = $"../Dialog"

@onready var music_h_slider: HSlider = $Option/VBoxContainer/Music/HSlider
@onready var sound_h_slider: HSlider = $Option/VBoxContainer/SoundEffect/HSlider
@onready var time_scale_h_slider: HSlider = $Option/VBoxContainer/TimeScale/HSlider
@onready var time_sacle_label: Label = $Option/VBoxContainer/TimeScale/Label


func _ready() -> void:
	## 为按钮添加音效
	SoundManager.setup_ui_main_game_sound(self)
	## 连接滑轨信号
	musci_sound_signal(music_h_slider, AudioServer.get_bus_index("BGM"))
	musci_sound_signal(sound_h_slider, AudioServer.get_bus_index("SFX"))
	time_sacle_signal(time_scale_h_slider)
	time_sacle_label.text = "倍速 " + str(Global.time_scale) + " 倍"

	
func musci_sound_signal(h_slider: HSlider, bus_index):
	
	h_slider.value = SoundManager.get_volum(bus_index)
	h_slider.value_changed.connect(func (v:float):
		SoundManager.set_volume(bus_index, v)
		Global.save_config()
	)
		

func time_sacle_signal(h_slider: HSlider):
	
	h_slider.value_changed.connect(func (v:float):
		Global.time_scale = v
		time_sacle_label.text = "倍速 " + str(Global.time_scale) + " 倍"
		Engine.time_scale = Global.time_scale
		)

## 出现菜单
func appear_menu():
	await get_tree().create_timer(0.1).timeout
	# 游戏暂停
	get_tree().paused = true
	SoundManager.play_sfx("Pause")

	visible = true
	#mouse_filter = Control.MOUSE_FILTER_STOP 

## 关闭菜单
func return_button_pressed():
	await get_tree().create_timer(0.1).timeout
	get_tree().paused = false
	visible = false
	#mouse_filter = Control.MOUSE_FILTER_IGNORE


## 图鉴
func encyclopedia():
	_unrealized()
	
## 重新开始
func resume_game():
	get_tree().paused = false
	get_tree().reload_current_scene()
	Global.time_scale = 1.0
	Engine.time_scale = Global.time_scale
	
	

## 返回主菜单
func return_main_menu():
	get_tree().paused = false
	get_tree().change_scene_to_file(Global.MainScenesMap[Global.MainScenes.StartMenu])

## 功能未实现
func _unrealized():
	dialog.appear_dialog()
