extends Node2D
class_name Hammer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var area_2d: Area2D = $Area2D
@onready var pow: Sprite2D = $Pow

@export_group("锤击出阳光相关")
## 是否掉落阳光
@export var can_sun := true
## 掉落阳光概率
@export var pred_sun :int = 10
## 阳光场景
@export var sun_scene: PackedScene
## 游戏中天降阳光的节点
@export var day_suns:DaySuns
## 掉落阳光价值
@export var sun_value := 25


func _ready() -> void:
	# 隐藏鼠标光标
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	## 恢复可见鼠标
	#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	day_suns = get_tree().root.get_node("MainGame/DaySuns")

func _process(delta):
	# 跟随鼠标移动
	position = get_global_mouse_position()
	

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			hammer_once()

## 锤击一次
func hammer_once():
	animation_player.stop()
	animation_player.play("Hammer_whack_zombie")
	SoundManager.play_other_SFX("swing")
	
	hammer_zombie()


# 创建阳光
func spawn_sun(create_global_position:Vector2):
	var new_sun = sun_scene.instantiate()
	if new_sun is Sun:
		
		day_suns.add_child(new_sun)
		new_sun.sun_value = sun_value
		new_sun._sun_scale(sun_value)
		# 控制阳光下落
		var tween = create_tween()
		new_sun.global_position = create_global_position
		
		var center_y : float = -15
		var target_y : float = 45
		tween.tween_property(new_sun, "position:y", center_y, 0.3).as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(new_sun, "position:y", target_y, 0.6).as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		
		var tween2 = create_tween()
		tween2.tween_property(new_sun, "position:x", randf_range(-30, 30), 0.9).as_relative()
		

		tween2.finished.connect(new_sun.on_sun_tween_finished)
		


func hammer_zombie():
	var overlapping_areas = area_2d.get_overlapping_areas()
	## 如果为空，直接退出该函数
	if overlapping_areas.is_empty():
		return
	
	## 选择最左边的僵尸area
	var area_be_choosed :Area2D
	# 遍历所有重叠的区域
	for area in overlapping_areas:
		if not area_be_choosed:
			area_be_choosed = area
		else:
			if area.global_position.x < area_be_choosed.global_position.x:
				area_be_choosed = area
	var zombie_be_choosed:ZombieBase = area_be_choosed.get_parent()
	var global_position_zombie_be_choosed = zombie_be_choosed.global_position

	## 锤子攻击僵尸,使用锤子攻击方法
	var zombie_is_death = zombie_be_choosed.be_attacked_hammer(1800)
	SoundManager.play_other_SFX("bonk")
	
	## 锤击僵尸掉落阳光
	if zombie_is_death:
		var curr_pred_value = randi_range(1,100)
		
		if curr_pred_value <= pred_sun:
			for i in range(3):
				spawn_sun(global_position_zombie_be_choosed)
	
	## 锤击僵尸特效
	var new_pow :Sprite2D= pow.duplicate() 
	new_pow.visible = true
	new_pow.global_position = global_position
	new_pow.z_as_relative = false
	new_pow.z_index = 951
	get_parent().add_child(new_pow)
	await get_tree().create_timer(0.5).timeout
	new_pow.queue_free()
	
