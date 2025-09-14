extends Zombie000Base
class_name Zombie018Digger

## 铁镐被吸铁石吸走后的问号
@onready var zombie_questionmark: Sprite2D = %ZombieQuestionmark
## 最后一格的x坐标
@export var digger_target_pos_x:float=88

@export_group("动画状态")
## 是否还在掘土状态
@export var is_dig := true
## 是否为正常退出掘土状态
@export var is_norm_end := true
## 跳起结束(被吸铁石吸走后使用)
@export var is_up_end := false
@onready var gpu_particles_dirt: GPUParticles2D = $GPUParticlesDirt

func init_norm():
	super()
	gpu_particles_dirt.emitting = true

## 初始化正常出战角色信号连接
func init_norm_signal_connect():
	super()
	attack_component.disable_component(ComponentBase.E_IsEnableFactor.DownGround)

## 每帧判断是否到达最后一格
func _process(delta: float) -> void:
	if is_dig:
		if global_position.x < digger_target_pos_x:
			## 更新方向
			update_direction_x_root(-1)
			dig_end()

## 挖掘结束,出土
func dig_end():
	gpu_particles_dirt.emitting = false
	curr_be_attack_status = E_BeAttackStatusZombie.IsNorm
	is_dig = false
	move_component.update_move_mode(MoveComponent.E_MoveMode.Ground)
	await zombie_up_from_ground()
	is_up_end = true


## 失去铁器道具
func loss_iron_item():
	super()
	if is_dig:
		move_component.update_move_mode(MoveComponent.E_MoveMode.Ground)
		## 非正常推出掘土状态
		is_norm_end = false
		charred_component.anim_lib_name = "ALL_ANIMS2"
		zombie_questionmark.visible = true
		await get_tree().create_timer(1.0,false).timeout
		zombie_questionmark.visible = false
		dig_end()

## 绝地结束出土结束(动画调用)
func dig_up_end():
	attack_component.enable_component(ComponentBase.E_IsEnableFactor.DownGround)


