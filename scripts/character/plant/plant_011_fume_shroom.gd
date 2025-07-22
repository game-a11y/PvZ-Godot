extends PuffShroom
class_name FumeShroom

## 大喷菇在植物本体添加粒子系统，子弹隐身穿透
@onready var gpu_particles_2d: GPUParticles2D = $Bullet_FX/GPUParticles2D

func _shoot_bullet():
	## 需要对子弹初始位置记录
	super._shoot_bullet()
	gpu_particles_2d.emitting = true

func _end_shoot():
	gpu_particles_2d.emitting = false
	
func play_throw_sfx():
	## 播放音效
	SoundManager.play_plant_SFX(Global.PlantType.FumeShroom, &"Fume")
