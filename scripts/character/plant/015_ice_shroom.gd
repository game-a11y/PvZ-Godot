extends PlantBase
class_name IceShroom

@export var is_sleep := true

@onready var sleep_shroom: ShroomSleep = $SleepShroom
@export var time_ice := 3.0
@export var time_decelerate := 3.0

@onready var bomb_effect: Node2D = $BombEffect

@export var SFX_bomb :AudioStreamPlayer

## 子节点SleepShroo会先更新is_sleep
func _ready() -> void:
	super._ready()
	## 植物默认睡眠，根据环境是否为白天判断睡眠状态
	sleep_shroom.judge_sleep()


func stop_sleep():
	is_sleep = false

func ice_all_zombie():
	var zombie_manager :ZombieManager= get_tree().current_scene.get_node("Manager/ZombieManager")
	zombie_manager.ice_all_zombie(time_ice, time_decelerate)
	var panel_ice: Panel_color = get_tree().current_scene.get_node("CanvasLayer_FX/Panel_Ice")
	panel_ice.appear_once()
	
	bomb_effect_change_parent(bomb_effect)
	bomb_effect.activate_bomb_effect()
	
	
	# SFX 爆炸植物死亡后销毁，将音效节点移至soundmanager
	SFX_bomb.get_parent().remove_child(SFX_bomb)
	SoundManager.add_child(SFX_bomb)
	SFX_bomb.play()
	
	
	_plant_free()
