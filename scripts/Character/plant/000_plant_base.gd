extends CharacterBase
class_name PlantBase

var be_shovel_look_color := Color(1, 1, 1)
@onready var bullets: Node2D = get_tree().current_scene.get_node("Bullets")

@export_group("植物眨眼相关")
@export var blink_sprite:Sprite2D				## 控制idle状态下植物眨眼
@export var blink_sprite_texture:Array[Texture]	## 控制植物眨眼纹理图片

var blink_timer :Timer	## 眨眼计时器

@export_group("动画状态是否可以眨眼,is_blink才会眨眼")
@export var is_blink := true

var Label_HP := preload("res://scenes/character/label_hp.tscn")

var label_hp :Label 
signal plant_free_signal(plant_base:PlantBase)

func _ready() -> void:
	super._ready()
	if blink_timer == null:
		# 创建 Timer 节点
		blink_timer = Timer.new()
		blink_timer.name = "BlinkTimer"
		blink_timer.wait_time = 5.0
		blink_timer.one_shot = false
		blink_timer.autostart = true
		add_child(blink_timer)
	# 连接 timeout 信号到函数
	blink_timer.timeout.connect(_on_blink_timer_timeout)
	
	# 血量显示
	label_hp = Label_HP.instantiate()
	add_child(label_hp)
	#label_hp.position = Vector2(70, 23)
	label_hp.text = str(curr_Hp)
	if Global.display_plant_HP_label:
		label_hp.visible = true
	else:
		label_hp.visible = false
	
func _on_blink_timer_timeout() -> void:
	## is_blink状态下眨眼
	if is_blink:
		do_blink()
	
	
func do_blink() -> void:
	blink_sprite.visible = true
	blink_sprite.texture = blink_sprite_texture[0]
	await get_tree().create_timer(0.1).timeout
	blink_sprite.texture = blink_sprite_texture[1]
	await get_tree().create_timer(0.1).timeout
	blink_sprite.texture = blink_sprite_texture[0]
	await get_tree().create_timer(0.1).timeout
	blink_sprite.visible = false
	

# 重写父类改变颜色方法
func _update_modulate():
	var final_color = base_color * _hit_color * debuff_color * be_shovel_look_color
	self.modulate = final_color

# 被铲子威胁
func be_shovel_look():
	be_shovel_look_color = Color(2, 2, 2)
	_update_modulate()
	
# 被铲子威胁结束
func be_shovel_look_end():
	be_shovel_look_color = Color(1, 1, 1)
	_update_modulate()


# 被攻击
func be_attacked(attack_value:int):
	curr_Hp -= attack_value
	label_hp.text = str(curr_Hp)

	judge_status()
	
func be_attacked_body_light():
	body_light()
	
func judge_status():
	if curr_Hp <= 0:
		_plant_free()

# 植物死亡
func _plant_free():
	plant_free_signal.emit(self)
	
	self.queue_free()
	
# 铲掉植物
func be_shovel_kill():
	_plant_free()
	

# 更换节点父节点
func bomb_effect_change_parent(bomb_effect:Node2D):
	# 保存全局变换
	var global_transform = bomb_effect.global_transform

	# 移除并添加到bullet节点
	bomb_effect.get_parent().remove_child(bomb_effect)
	bullets.add_child(bomb_effect)

	# 恢复全局变换，保持位置不变
	bomb_effect.global_transform = global_transform
