extends TextureButton
class_name ChooseLevelButton

@export var curr_level := Global.MainGameLevel.FrontDay
@onready var choose_level: ChooseLevel = $"../../../.."


func _on_pressed() -> void:
	Global.main_game_level = curr_level
	choose_level.choose_level_start_game()
	
