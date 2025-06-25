extends PlantBase
class_name CherryBomb

@export var is_bomb := true
## 爆炸音效
@export var SFX_bomb :AudioStreamPlayer
@onready var bomb_effect = $BombEffect

# 爆炸检测碰撞体
@onready var area_2d_2: Area2D = $Area2D2


# 爆炸效果
func _bomb_particle():
	if SFX_bomb:
		# SFX 爆炸植物死亡后销毁，将音效节点移至soundmanager
		SFX_bomb.get_parent().remove_child(SFX_bomb)
		SoundManager.add_child(SFX_bomb)
		SFX_bomb.play()
	
	bomb_effect_change_parent(bomb_effect)
	bomb_effect.activate_bomb_effect()
	_plant_free()


func _bomb_all_area_zombie():
	var areas = area_2d_2.get_overlapping_areas()
	for area in areas:
		area.get_parent().be_bomb_death()
	
	_bomb_particle()
	
