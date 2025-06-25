extends PlantBase
class_name HypnoShroom

var is_eated := false
@onready var sleep_shroom: ShroomSleep = $SleepShroom

## 发出音效后消失的植物，需要把音效拎出来
@export var SFX_bomb :AudioStreamPlayer

@export var is_sleep := true


## 子节点SleepShroo会先更新is_sleep
func _ready() -> void:
	super._ready()
	## 植物默认睡眠，根据环境是否为白天判断睡眠状态
	sleep_shroom.judge_sleep()


func stop_sleep():
	is_sleep = false


func be_eated_once(zombie:ZombieBase):
	if not is_eated:
		is_eated = true
		zombie.be_hypnotized()

		# SFX 爆炸植物死亡后销毁，将音效节点移至soundmanager
		SFX_bomb.get_parent().remove_child(SFX_bomb)
		SoundManager.add_child(SFX_bomb)
		SFX_bomb.play()
	
		
		_plant_free()
