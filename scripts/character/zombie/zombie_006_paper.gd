extends ZombieBase
class_name ZombiePaper

@export var is_gasp := false
func arm2_drop():
	super.arm2_drop()
	is_gasp = true
	SoundManager.play_zombie_SFX(Global.ZombieType.ZombiePaper, "Rip")
		
	
func _gasp_end():
	_curr_damage_per_second = damage_per_second * 2
	$Body/Anim_head_look.visible = false
	$Body/Anim_head_pupils.visible = false
	SoundManager.play_zombie_SFX(Global.ZombieType.ZombiePaper, "Rarrgh")

	
