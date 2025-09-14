extends Node2D
class_name ShroomSleep

## 用于管理蘑菇睡觉
var root_node : MainGameManager
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func judge_sleep():
	if get_tree().current_scene is MainGameManager:
		root_node = get_tree().current_scene
		## 睡眠
		if root_node.game_para.game_BG != root_node.game_para.GameBg.FrontNight:
			get_parent().is_sleep = true
			animation_player.play("zzz")
			visible = true
		else:
			get_parent().stop_sleep()
			animation_player.stop()
			visible = false
	else:
		get_parent().stop_sleep()
		animation_player.stop()
		visible = false


func immediate_hide_zzz():
	visible = false
