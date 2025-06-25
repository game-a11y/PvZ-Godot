extends PlantBase
class_name SunFlower
@onready var production_timer: Timer = $ProductionTimer
@export var sun_scene: PackedScene

@export var production_interval: float  # 生产间隔(秒)
## 从该位置生成阳光
@onready var sun: Node2D = $Sun
# 阳光交互，将生产阳光放到DaySuns下，不然会被植物的button按钮挡住
@export var day_suns:DaySuns
## 生产阳光价值
@export var sun_value := 25



func _ready():
	super._ready()
	
	production_interval = randf_range(3, 12.5)
	production_timer.timeout.connect(_on_production_timer_timeout)
	production_timer.start(production_interval)
	day_suns = get_tree().root.get_node("MainGame/DaySuns")
	#spawn_sun()
	
func _on_production_timer_timeout():
	create_sun()
	change_production_interval()

# 创建阳光
func spawn_sun():
	# SFX 向日葵生产阳光
	$Throw.play()
	
	var new_sun = sun_scene.instantiate()
	if new_sun is Sun:
		
		day_suns.add_child(new_sun)
		new_sun.sun_value = sun_value
		new_sun._sun_scale(sun_value)
		# 控制阳光下落
		var tween = get_tree().create_tween()
		new_sun.global_position = sun.global_position
		
		var center_y : float = -15
		var target_y : float = 45
		tween.tween_property(new_sun, "position:y", center_y, 0.3).as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(new_sun, "position:y", target_y, 0.6).as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		
		var tween2 = get_tree().create_tween()
		tween2.tween_property(new_sun, "position:x", randf_range(-30, 30), 0.9).as_relative()
		

		tween2.finished.connect(new_sun.on_sun_tween_finished)
		


func change_production_interval():
	production_interval = randf_range(23.5,25)
	production_timer.start(production_interval)



# 身体发光函数
func create_sun():

	# 创建新的 tween
	var tween = get_tree().create_tween()
	
	tween.tween_property(self, "modulate",  Color(2, 2, 2), 0.5)
	# 在第一个 tween 完成后、第二个 tween 开始前调用函数
	tween.tween_callback(Callable(self, "spawn_sun"))
	tween.tween_property(self, "modulate", Color(1, 1, 1), 0.5)
	
