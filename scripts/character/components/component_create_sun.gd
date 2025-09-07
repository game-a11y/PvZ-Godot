extends ComponentBase
class_name CreateSunComponent

## 生产阳光计时器
@onready var create_sun_timer: Timer = $CreateSunTimer
## 身体, 控制发光
@onready var body: BodyCharacter = %Body


## 生产阳光价值
@export var sun_value := 25
## 生产光位置
@export var marker_2d_create_sun: Marker2D

@export_group("生产间隔时间")
## 第一个阳光生产时间范围
@export var create_time_range_first:Vector2 = Vector2(3, 12.5)
## 后续生产阳光的时间范围
@export var create_time_range_other:Vector2 = Vector2(23.5,25)
## 阳光生产速度
var create_speed := 1.0

## 阳光生产间隔
var create_interval :float
## 创建阳光时的发光颜色
var create_sun_color: Color = Color(1, 1, 1)


func _ready() -> void:
	if get_tree().current_scene != MainGameManager:
		return
	create_interval = randf_range(create_time_range_first.x, create_time_range_first.y)
	create_sun_timer.start(create_interval)


## 启用组件
func enable_component(is_enable_factor:E_IsEnableFactor):
	super(is_enable_factor)
	create_sun_timer.start(create_sun_timer.wait_time / create_speed)

## 禁用组件
func disable_component(is_enable_factor:E_IsEnableFactor):
	super(is_enable_factor)
	create_sun_timer.stop()

func owner_update_speed(speed_product:float):
	if is_enabling:
		if not create_sun_timer.is_stopped():
			if speed_product == 0:
				create_sun_timer.paused = true
			else:
				create_sun_timer.paused = false

				create_sun_timer.start(create_sun_timer.time_left / speed_product)

	create_speed = speed_product


## 生产阳光后、改变阳光生产时间，重新启动计时器
func change_production_interval():
	create_interval = randf_range(create_time_range_other.x / create_speed, create_time_range_other.y / create_speed)
	create_sun_timer.start(create_interval)


## 创建阳光
func _spawn_sun():
	## 播放音效
	SoundManager.play_plant_SFX(Global.PlantType.SunFlower, &"Throw")

	var new_sun:Sun = SceneRegistry.SUN.instantiate()
	new_sun.init_sun(sun_value, MainGameDate.suns.to_local(marker_2d_create_sun.global_position))
	MainGameDate.suns.add_child(new_sun)

	# 控制阳光下落
	var tween = create_tween()
	var center_y : float = -15
	var target_y : float = 45
	tween.tween_property(new_sun, "position:y", center_y, 0.3).as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(new_sun, "position:y", target_y, 0.6).as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	new_sun.spawn_sun_tween = get_tree().create_tween()
	new_sun.spawn_sun_tween.set_parallel()
	new_sun.spawn_sun_tween.tween_subtween(tween)
	new_sun.spawn_sun_tween.tween_property(new_sun, "position:x", randf_range(-30, 30), 0.9).as_relative()

	new_sun.spawn_sun_tween.finished.connect(new_sun.on_sun_tween_finished)


## 创建阳光全流程：身体发光、生产阳光、身体不发光
func create_sun():
	# 创建新的 tween
	var tween = create_tween()
	tween.tween_method(func(val): body.set_other_color(BodyCharacter.E_ChangeColors.CreateSunColor, val), Color(1, 1, 1), Color(2, 2, 2), 0.5)
	# 在第一个 tween 完成后、第二个 tween 开始前调用函数
	tween.tween_callback(Callable(self, "_spawn_sun"))
	tween.tween_method(func(val): body.set_other_color(BodyCharacter.E_ChangeColors.CreateSunColor, val), Color(2, 2, 2), Color(1, 1, 1), 0.5)


func _on_create_sun_timer_timeout() -> void:
	create_sun()
	change_production_interval()

## 改变阳光生产价值
func change_sun_value(sun_value:int):
	self.sun_value = sun_value
