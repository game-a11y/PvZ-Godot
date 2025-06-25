extends CherryBomb
class_name DoomShroom


@export var is_sleep := true
@onready var sleep_shroom: ShroomSleep = $SleepShroom

## 子节点SleepShroo会先更新is_sleep
func _ready() -> void:
	super._ready()
	## 植物默认睡眠，根据环境是否为白天判断睡眠状态
	sleep_shroom.judge_sleep()


func stop_sleep():
	is_sleep = false


# 爆炸效果
func _bomb_particle():
	if get_parent() is PlantCell:
		var plantcell:PlantCell = get_parent()
		plantcell.create_crater()
	super._bomb_particle()
	
	var panel_doom: Panel_color = get_tree().current_scene.get_node("CanvasLayer_FX/Panel_Doom")
	panel_doom.appear_once()
	
