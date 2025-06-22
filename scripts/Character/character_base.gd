extends Node2D
class_name CharacterBase
# 植物和僵尸的基础类

@export var max_hp :int = 300
@export var curr_Hp : int

var hit_tween: Tween = null  # 发光动画
var decelerate_timer: Timer  # 减速计时器

@onready var animation_tree: AnimationTree = $AnimationTree
@export var animation_origin_speed: float  # 初始动画速度
@export var animation_speed_random: float  # 初始随机速度波动

@export var is_decelerated := false

# modulate 状态颜色变量
var base_color := Color(1, 1, 1)

# 需要逐帧更新，使用set中_update_modulate()
var _hit_color: Color = Color(1, 1, 1)
func set_hit_color(value: Color) -> void:
	_hit_color = value
	_update_modulate()
func get_hit_color() -> Color:
	return _hit_color
	
var debuff_color := Color(1, 1, 1)

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

	# 初始化颜色
	_update_modulate()
	
	curr_Hp = max_hp

# 更新最终 modulate 的合成颜色
func _update_modulate():
	var final_color = base_color * _hit_color * debuff_color
	self.modulate = final_color

# 发光动画函数
func body_light():
	_hit_color = Color(2, 2, 2)  # 会触发 set_hit_color -> _update_modulate

	if hit_tween and hit_tween.is_running():
		hit_tween.kill()

	hit_tween = get_tree().create_tween()
	hit_tween.tween_method(set_hit_color, _hit_color, Color(1, 1, 1), 0.5)

# 被减速处理
func be_decelerated(time_decelerate: float):
	animation_tree.set("parameters/TimeScale/scale", animation_origin_speed * 0.5)
	debuff_color = Color(0.4, 1, 1)
	_update_modulate()
	is_decelerated = true
	start_timer_be_decelerated(time_decelerate)

# 启动/重置减速计时器
func start_timer_be_decelerated(wait_time: float):
	if decelerate_timer.time_left > 0:
		decelerate_timer.stop()
	decelerate_timer.wait_time = wait_time
	decelerate_timer.start()

# 减速恢复回调
func _on_timer_timeout_time_decelerate():
	animation_tree.set("parameters/TimeScale/scale", animation_origin_speed)
	debuff_color = Color(1, 1, 1)
	_update_modulate()
	is_decelerated = false
