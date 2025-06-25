extends PlantBase
class_name Chomper

@export var is_strat_eat := false
@export var is_eating := false
@export var is_end_eat := false
# 咀嚼时间
@export var eat_CD :float = 5

# 检测射线
@onready var ray_cast_2d: RayCast2D = $RayCast2D

# 咀嚼僵尸计时器
@onready var timer: Timer = $Timer


func _ready() -> void:
	super._ready()
	# timer初始化，大嘴花咀嚼计时器
	timer.wait_time = eat_CD
	timer.one_shot = true  # 单次执行
	timer.timeout.connect(_eat_end)  # 无参数
	
	blink_timer.stop()
	is_blink = false
	

# 检测是否有僵尸
func _process(delta):
	# 每帧检查射线是否碰到僵尸
	if ray_cast_2d.is_colliding():
		if not is_strat_eat:
			is_strat_eat = true
		
	else:
		if is_strat_eat:
			is_strat_eat = false


# 大嘴花吃掉僵尸
func _eat_zombie():
	# SFX 大嘴花吃僵尸
	$Bigchomp.play()
	if ray_cast_2d.is_colliding():
		var collider = ray_cast_2d.get_collider()
		#如果有僵尸
		if collider != null:
			var parent :ZombieBase= collider.get_parent()

			if not parent.area2d_free:
				parent.disappear_death()
				is_eating = true
			
				is_end_eat = false
				timer.start()
			else:
				is_eating = false
			
	else :
		is_eating = false

# 大嘴花吃完一次
func _eat_end():
	is_end_eat = true
	
	
