extends Area2D
class_name Area2DHome


func _on_area_entered(area: Area2D) -> void:
	# 游戏暂停
	get_tree().paused = true
	$Dialog.visible = true
	
	
## 重新开始
func resume_game():
	get_tree().paused = false
	get_tree().reload_current_scene()
	
	Global.time_scale = 1.0
	Engine.time_scale = Global.time_scale
	
