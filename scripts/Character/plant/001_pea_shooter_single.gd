extends PlantBase
class_name PeaShooterSingle

@export var is_attack: bool = false

@onready var ray_cast_2d: RayCast2D = $RayCast2D

@export var bullet_pea_scene : PackedScene
@onready var bullet_position = $Body/Anim_stem/stem_correct/Projectile

## 攻击冷却时间计时器
var attack_timer:Timer

func _ready():
	super._ready()
	# 创建计时器，循环触发
	attack_timer = Timer.new()
	attack_timer.name = "AttackTimer"
	attack_timer.wait_time = 2.0 / animation_origin_speed # 每次间隔，比如 1 秒攻击一次
	attack_timer.one_shot = false
	add_child(attack_timer)
	
	# 连接 timeout 信号
	attack_timer.timeout.connect(_on_attack_timer_timeout)

# 启动连续攻击（每 attack_timer.wait_time 秒攻击一次）
func start_attack_loop():
	if not attack_timer.is_stopped():
		return # 已在运行就不重复启动
	## 避免攻击时眨眼
	blink_sprite.visible = false
	attack_timer.start()

# 停止攻击
func stop_attack_loop():
	attack_timer.stop()

# 每次触发执行攻击
func _on_attack_timer_timeout():
	animation_tree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	# 在这里调用实际攻击逻辑

func _process(delta):

	# 每帧检查射线是否碰到僵尸
	if ray_cast_2d.is_colliding():
		if not is_attack:
			is_attack = true
			is_blink = false
			## 攻击一次，并启动计时器循环触发攻击
			animation_tree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
			start_attack_loop()
		
	else:
		if is_attack:
			is_attack = false
			is_blink = true
			stop_attack_loop()
	
	
func _shoot_bullet():
	var bullet = bullet_pea_scene.instantiate()
	
	bullets.add_child(bullet)
	bullet.global_position = bullet_position.global_position
	# SFX 豌豆射手发射豌豆
	get_node("Throw" + str(randi_range(1, 2))).play()
