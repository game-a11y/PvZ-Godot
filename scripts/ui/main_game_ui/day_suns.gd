extends Node2D
class_name DaySuns


@export var sun_scene: PackedScene
@export var production_interval: float  # 生产间隔(毫秒)
@export var curr_sun_sum_value := 0

@onready var production_timer: Timer = $Timer

@export var sun_x_min : float = 50
@export var sun_x_max : float = 750

@export var sun_y_min : float = 130
@export var sun_y_max : float = 550

@export var sun_y_ori : float = -40

@export var sun_y_speed : float = 200


func _ready():
	production_interval = 10 * curr_sun_sum_value + 425
	production_timer.timeout.connect(_on_production_timer_timeout)

	#for i in range(100):
		#spawn_sun()
	
func start_day_sun():
	production_timer.start(production_interval/100)

func _on_production_timer_timeout():
	spawn_sun()
	change_production_interval()

# 创建阳光
func spawn_sun():
	var new_sun = sun_scene.instantiate()
	if new_sun is Sun:
		add_child(new_sun)
		curr_sun_sum_value += new_sun.sun_value
		# 控制阳光下落
		var tween = get_tree().create_tween()
		new_sun.position = Vector2(randf_range(sun_x_min, sun_x_max), sun_y_ori)
		var target_y = randf_range(sun_y_min, sun_y_max)
		var distance = float(abs(target_y - sun_y_ori))
		var duration = distance / sun_y_speed
		tween.tween_property(new_sun, "position:y", target_y, duration)
		
		tween.finished.connect(new_sun.on_sun_tween_finished)
		

		
func change_production_interval():
	
	var A : float = 10 * curr_sun_sum_value + 425
		# 下次天降阳光时间
	if A<950:
		production_interval = (A + randf_range(0,274))
	else:
		production_interval = 950 + randf_range(0,274)
	
	production_timer.start(production_interval/100)
