extends Node2D
class_name CharacterBase
# 植物和僵尸的基础类

@export var max_hp :int = 300
@export var curr_Hp : int

var hit_tween: Tween = null  # 发光动画
var decelerate_timer: Timer  # 减速计时器
var ice_timer: Timer  		# 冰冻计时器

@onready var animation_tree: AnimationTree = $AnimationTree
@export var animation_origin_speed: float  # 初始动画速度
@export var animation_speed_random: float  # 初始随机速度波动

@export var is_decelerated := false
@export var is_iced := false

## 被冰冻和减速的时间，每次被冰冻或减速时修改
var _be_iced_time: float = 3.0
var _be_decelerated_time: float = 3.0

# modulate 状态颜色变量
var base_color := Color(1, 1, 1)
@onready var body: Node2D = $Body

# 需要逐帧更新，使用set中_update_modulate()
var _hit_color: Color = Color(1, 1, 1)
func set_hit_color(value: Color) -> void:
	_hit_color = value
	_update_modulate()
func get_hit_color() -> Color:
	return _hit_color
	
var debuff_color := Color(1, 1, 1)

## 血量显示
var Label_HP := preload("res://scenes/character/label_hp.tscn")
var label_hp :Label 

func _ready() -> void:
	# 获取动画初始速度
	animation_origin_speed = animation_tree.get("parameters/TimeScale/scale")
	animation_speed_random = randf_range(0.9, 1.1)
	animation_origin_speed *= animation_speed_random
	animation_tree.set("parameters/TimeScale/scale", animation_origin_speed)
	
	# 创建减速计时器
	decelerate_timer = Timer.new()
	decelerate_timer.name = "decelerate_timer"
	decelerate_timer.one_shot = true
	add_child(decelerate_timer)
	decelerate_timer.timeout.connect(_on_timer_timeout_time_decelerate)
	# 创建冰冻计时器
	ice_timer = Timer.new()
	ice_timer.name = "ice_timer"
	ice_timer.one_shot = true
	add_child(ice_timer)
	ice_timer.timeout.connect(_on_timer_timeout_time_ice)

	# 初始化颜色
	_update_modulate()
	
	curr_Hp = max_hp
	
	# 血量显示
	label_hp = Label_HP.instantiate()
	add_child(label_hp)

# 更新最终 modulate 的合成颜色
func _update_modulate():
	var final_color = base_color * _hit_color * debuff_color
	body.modulate = final_color

# 发光动画函数
func body_light():
	_hit_color = Color(2, 2, 2)  # 会触发 set_hit_color -> _update_modulate

	if hit_tween and hit_tween.is_running():
		hit_tween.kill()

	hit_tween = get_tree().create_tween()
	hit_tween.tween_method(set_hit_color, _hit_color, Color(1, 1, 1), 0.5)

# 被减速处理
func be_decelerated(time_decelerate:float):
	# 如果还在被冰冻，忽略
	if is_iced:
		return
	_be_decelerated_time = time_decelerate
	animation_tree.set("parameters/TimeScale/scale", animation_origin_speed * 0.5)
	debuff_color = Color(0.4, 1, 1)
	_update_modulate()
	is_decelerated = true
	start_timer(_be_decelerated_time, decelerate_timer)

# 被冰冻
func be_ice(time_ice:float, time_decelerate: float):
	_be_iced_time = time_ice
	_be_decelerated_time = time_decelerate
	animation_tree.set("parameters/TimeScale/scale", 0)
	debuff_color = Color(0.4, 1, 1)
	_update_modulate()
	is_iced = true
	start_timer(time_ice, ice_timer)


# 启动/重置计时器 冰冻和减速
func start_timer(wait_time: float, timer:Timer):
	if timer.time_left > 0:
		timer.stop()
	timer.wait_time = wait_time
	timer.start()

# 减速恢复回调
func _on_timer_timeout_time_decelerate():
	# 如果还在被冰冻，忽略
	if is_iced:
		return
	
	is_decelerated = false
	
	animation_tree.set("parameters/TimeScale/scale", animation_origin_speed)
	debuff_color = Color(1, 1, 1)
	_update_modulate()

# 冰冻恢复减速
func _on_timer_timeout_time_ice():
	is_iced = false
	be_decelerated(_be_decelerated_time)



#region 被攻击
#被子弹攻击
## 被子弹攻击，僵尸子类重写
func be_attacked_bullet(attack_value:int, bullet_mode : Global.BulletMode):
	## 掉血，发光
	Hp_loss(attack_value, bullet_mode)
	be_attacked_body_light()


# 被僵尸啃咬攻击
func be_eated(attack_value:int, zombie):
	# 被僵尸啃咬子弹属性为真实伤害（略过2类防具，直接对1类防具和血量攻击）
	Hp_loss(attack_value, Global.BulletMode.real)
	

# 掉血，子类重写
func Hp_loss(attack_value:int, bullet_mode : Global.BulletMode = Global.BulletMode.Norm):
	#label_hp.text = str(curr_Hp)
	pass

## 被攻击时发光，攻击者调用
func be_attacked_body_light():
	body_light()

## 被啃食一次
func be_eated_once(zombie:ZombieBase):
	be_attacked_body_light()

#endregion
