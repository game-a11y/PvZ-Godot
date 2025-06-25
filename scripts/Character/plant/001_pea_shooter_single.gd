extends PlantBase
class_name PeaShooterSingle

@export var is_attack: bool = false

@onready var ray_cast_2d: RayCast2D = $RayCast2D

@export var bullet_scene : PackedScene
@export var bullet_position :Node2D
@export var attack_cd := 2.0
@export var throw_SFX : Array[AudioStreamPlayer]
## 攻击冷却时间计时器
var attack_timer:Timer

func _ready():
	super._ready()
	# 创建计时器，循环触发
	attack_timer = Timer.new()
	attack_timer.name = "AttackTimer"
	attack_timer.wait_time = attack_cd / animation_origin_speed # 每次间隔，比如 1 秒攻击一次
	attack_timer.one_shot = false
	add_child(attack_timer)
	
	# 连接 timeout 信号
	attack_timer.timeout.connect(_on_attack_timer_timeout)

# 启动连续攻击（每 attack_timer.wait_time 秒攻击一次）
func start_attack_loop():
	if not attack_timer.is_stopped():
		return # 已在运行就不重复启动
		
	if blink_sprite:
		## 避免攻击时眨眼
		blink_sprite.visible = false

	attack_timer.start()

# 停止攻击,
#TODO: 有可能不停止，不知道原因，时间结束回调函数进行重复判定
func stop_attack_loop():
	attack_timer.stop()

# 每次触发执行攻击
func _on_attack_timer_timeout():
	# 在这里调用实际攻击逻辑
	if not is_attack:
		attack_timer.stop()
		return
		
	animation_tree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
	

func _process(delta):
	# 每帧检查射线是否碰到僵尸
	if ray_cast_2d.is_colliding():
		if not is_attack:
			is_attack = true
			is_blink = false
			## 如果没有这个等待时间，大喷菇概率隐身，不清楚原因
			await get_tree().create_timer(randf_range(0.5, 1)).timeout
			## 攻击一次，并启动计时器循环触发攻击
			_on_attack_timer_timeout()
			start_attack_loop()
		
	else:
		if is_attack:
			is_attack = false
			is_blink = true
			stop_attack_loop()
	
	
func _shoot_bullet():
	var bullet = bullet_scene.instantiate()
	
	bullets.add_child(bullet)
	bullet.global_position = bullet_position.global_position
	
	bullet.start_pos = bullet.global_position
	## 攻击音效
	if throw_SFX.size() > 0:
		throw_SFX[randi() % throw_SFX.size()].play()
	
