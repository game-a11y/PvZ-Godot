extends SunFlower
class_name SunShroom

@export var is_sleep := true
@export var is_grow := false
@export var grow_time :float = 100
@onready var grow_timer: Timer = $GrowTimer
@onready var sleep_shroom: ShroomSleep = $SleepShroom

## 子节点SleepShroo会先更新is_sleep
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	
	# 长大计时器
	grow_timer.wait_time = grow_time
	grow_timer.timeout.connect(_on_grow_timer_timeout)
	grow_timer.start()

	## 植物默认睡眠, 停止生产阳光计时器,停止长大计时器
	production_timer.paused = true
	grow_timer.paused = true
	
	## 植物默认睡眠，根据环境是否为白天判断睡眠状态
	sleep_shroom.judge_sleep()
	
	
func _on_grow_timer_timeout():
	is_grow = true
	sun_value = 25
	$Plantgrow.play()


func stop_sleep():
	is_sleep = false
	# 开始生产阳光计时器,长大计时器
	production_timer.paused = false
	grow_timer.paused = false
