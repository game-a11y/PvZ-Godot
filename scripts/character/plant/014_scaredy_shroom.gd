extends PuffShroom
class_name ScaredyShroom

@onready var area_2d_2: Area2D = $Area2D2
@export var is_scared := false

@export var num_zombie_in_scaredy_area := 0
	
	
## 判断是否会害怕
func judge_scared():
	if num_zombie_in_scaredy_area <= 0 and is_scared:
		is_scared = false
	elif num_zombie_in_scaredy_area > 0 and not is_scared:
		is_scared = true
	
# 重写攻击逻辑
func _on_attack_timer_timeout():
	if not is_scared:
		animation_tree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	# 在这里调用实际攻击逻辑


## 检测有僵尸进入
func _on_area_2d_2_area_entered(area: Area2D) -> void:
	num_zombie_in_scaredy_area += 1
	judge_scared()
	
	
func _on_area_2d_2_area_exited(area: Area2D) -> void:
	num_zombie_in_scaredy_area -= 1
	judge_scared()
