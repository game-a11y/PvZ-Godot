extends BulletLinear000Base
class_name Bullet1001Bowling

@onready var body_correct: Node2D = $Body/BodyCorrect
## 旋转速度
var rotation_speed = 5.0
## 每行的y坐标
var y_every_lane:Array[float]
## 第一次攻击是否完成
var first_attack_end := false
## 是否在当前行,为true时可以攻击
var in_curr_lane := true
## 当前的碰撞敌人,到达当前行后对当前敌人攻击
var curr_enemy :Character000Base


func _ready() -> void:
	super._ready()
	for i_zombie_row_node:ZombieRow in MainGameDate.all_zombie_rows:
		y_every_lane.append(i_zombie_row_node.zombie_create_position.global_position.y - 10)
	SoundManager.play_bullet_attack_SFX(SoundManager.TypeBulletSFX.Bowling)

## 初始化子弹属性
func init_bullet(lane:int, start_pos:Vector2, direction:= Vector2.RIGHT, bullet_lane_activate:bool=default_bullet_lane_activate):
	super(lane, start_pos, direction, bullet_lane_activate)
	z_as_relative = false
	z_index = 415 + lane * 10


func _process(delta: float) -> void:
	super._process(delta)
	body_correct.rotation += rotation_speed * delta
	## 如果第一次攻击已完成，碰到边缘时
	if first_attack_end:
		## 如果超过第0行
		if global_position.y < y_every_lane[0]:
			bullet_lane = 0
			_update_direction()
		## 如果超过第最后一行
		if global_position.y > y_every_lane[-1] + 5:
			bullet_lane = y_every_lane.size() - 1
			_update_direction()

	## 如果到达目标行
	if not in_curr_lane and (y_every_lane[bullet_lane] - 10 < global_position.y and global_position.y < y_every_lane[bullet_lane] + 10):
		## 查看是否有僵尸在攻击范围内
		if curr_enemy:
			## 如果僵尸在子弹攻击行
			if bullet_lane == curr_enemy.lane:
				attack_once(curr_enemy)
				_update_direction()
		else:
			in_curr_lane = true

	## 移动离开当前行后，更新当前
	if in_curr_lane and (y_every_lane[bullet_lane] - 10 > global_position.y or global_position.y > y_every_lane[bullet_lane] + 10):
		in_curr_lane = false	# 修改当前行
		update_z_index_and_lane(bullet_lane, bullet_lane + direction.y)


## 更新图层
func update_z_index_and_lane(curr_lane:int, target_lane:int):
	##第0行僵尸z_index = 410
	if curr_lane > target_lane:
		z_index = 415 + target_lane * 10
	else:
		z_index = 415 + (target_lane - 1) * 10
	bullet_lane = target_lane

## 更新保龄球移动方向
func _update_direction():
	if bullet_lane == 0:
		direction.y = 1
	elif bullet_lane == y_every_lane.size() - 1:
		direction.y = -1
	else:
		if direction.y == 0:
			direction.y = 1 if randf() > 0.5 else -1
		else:
			direction.y *= -1

	update_z_index_and_lane(bullet_lane, bullet_lane + direction.y)

## 子弹与敌人碰撞
func _on_area_2d_attack_area_entered(area: Area2D) -> void:
	var enemy:Character000Base = area.owner
	## TODO:攻击植物子弹
	if enemy is Plant000Base:
		push_error("保龄球攻击植物敌人")
		return
	elif enemy is Zombie000Base:
		var zombie = enemy as Zombie000Base
		## 如果不是可攻击状态敌人
		if not zombie.curr_be_attack_status & can_attack_zombie_status:
			return
	else:
		push_error("敌人不是植物,不是僵尸")
	## 在当前行
	if in_curr_lane:
		print(bullet_lane, enemy.lane)
		## 如果僵尸在子弹攻击行
		if bullet_lane == enemy.lane:
			## 攻击后修改为不再当前行，并已攻击
			in_curr_lane = false
			attack_once(enemy)
			_update_direction()
			first_attack_end = true
			bullet_mode = Global.AttackMode.BowlingSide
	else :
		curr_enemy = area.owner

## 子弹离开当前敌人
func _on_area_2d_attack_area_exited(area: Area2D) -> void:
	if curr_enemy == area.owner:
		curr_enemy = null
