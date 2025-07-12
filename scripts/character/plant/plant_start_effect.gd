extends Node2D
class_name PlantStartEffect

## 种植植物时的特效，泥土或水粒子效果

@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@export var SFX_create_new_plant:Array[AudioStreamPlayer]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play_and_wait_particles(gpu_particles_2d)
	

## 粒子特效完成后，删除该节点
func play_and_wait_particles(particles: GPUParticles2D) -> void:
	particles.restart()  # 重启粒子播放
	if SFX_create_new_plant:
		SFX_create_new_plant.pick_random().play()
	await get_tree().create_timer(particles.lifetime + 0.1).timeout
	queue_free()
