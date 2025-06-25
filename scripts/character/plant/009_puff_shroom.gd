extends PeaShooterSingle
class_name PuffShroom

@export var is_sleep := true

@onready var sleep_shroom: ShroomSleep = $SleepShroom

## 子节点SleepShroo会先更新is_sleep
func _ready() -> void:
	super._ready()
	## 植物默认睡眠，根据环境是否为白天判断睡眠状态
	sleep_shroom.judge_sleep()


# 睡眠
func _process(delta: float) -> void:
	if not is_sleep:
		super._process(delta)


func stop_sleep():
	is_sleep = false
	
