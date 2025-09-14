extends PlantBase
class_name IceShroom

@export var is_sleep := true

@onready var sleep_shroom: ShroomSleep = $SleepShroom
@export var time_ice := 3.0
@export var time_decelerate := 3.0

@onready var bomb_effect: Node2D = $BombEffect

@export var SFX_bomb :AudioStreamPlayer
var is_bomb_end := false
## 子节点SleepShroo会先更新is_sleep
func _ready() -> void:
	super._ready()
	## 植物默认睡眠，根据环境是否为白天判断睡眠状态
	sleep_shroom.judge_sleep()


func stop_sleep():
	is_sleep = false
	
func judge_death_bomb(plant:PlantBase):
	if not is_bomb_end:
		is_bomb_end = true
		ice_all_zombie()

func ice_all_zombie():
	if not is_idle and not is_bomb_end:
		is_bomb_end = true
		var zombie_manager :ZombieManager= get_tree().current_scene.get_node("Manager/ZombieManager")
		zombie_manager.ice_all_zombie(time_ice, time_decelerate)
		var panel_ice: Panel_color = get_tree().current_scene.get_node("CanvasLayer_FX/Panel_Ice")
		panel_ice.appear_once()
		child_node_change_parent(bomb_effect, bullets)
		bomb_effect.activate_bomb_effect()
		
		SoundManager.play_plant_SFX(Global.PlantType.IceShroom, &"Frozen")
		
		
		_plant_free()
	
func keep_idle():
	super.keep_idle()
	sleep_shroom.immediate_hide_zzz()
	stop_sleep()
