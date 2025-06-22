extends CharacterBase
class_name ZombieBase

#region 僵尸基础属性
@export_group("僵尸基础属性")
## 僵尸类型
@export var zombie_type : Global.ZombieType
## 僵尸攻击力每帧扣血
var frame_counter := 0
@export var damage_per_second := 100
var _curr_damage_per_second : int
var _curr_plant :PlantBase

## 僵尸所在行
@export var lane : int
## 僵尸所属波次
@export var curr_wave:int = -1
## 僵尸受击音效是否为铁器防具 一类防具
@export var be_bullet_SFX_is_shield_first := false
## 僵尸受击音效是否为铁器防具 二类防具
@export var be_bullet_SFX_is_shield_second := false

#endregion

#region 僵尸状态，用于动画改变
@export_group("僵尸状态")
@export_subgroup("管理僵尸动画")
@export var is_idle := false
@export var is_walk := true			## 默认为移动状态
@export var is_attack := false
@export var is_death := false

@export_subgroup("管理僵尸死亡")
## 僵尸是否删除碰撞器，表示僵尸是否死亡，用于传递僵尸被击杀信号
@export var area2d_free:bool = false
#endregion

#region 僵尸防具血量变化

@export_group("僵尸防具血量变化")
@export_subgroup("血量状态")
@export var curr_hp_status := 1			## 血量状态

@export var zombie_outerarm_upper: Sprite2D							## 上半胳膊
@export var zombie_outerarm_upper_sprite2d_textures : Texture2D		## 上半胳膊残血图片

@export var zombie_status_2_fade: Array[Sprite2D]					## 僵尸血量状态2时隐藏精灵图（下半胳膊和手）
@export var hand_drop: Node2D		## 僵尸掉落的手

@export var zombie_status_3_fade: Array[Sprite2D]					## 僵尸血量状态3时隐藏精灵图（头部）
@export var head_drop: Node2D		## 僵尸掉落的头


@export_subgroup("一类防具状态")
@export var curr_armor_1_hp_status := 1

@export var armor_first_max_hp := 0
@export var armor_first_curr_hp : int

@export var armor_1_sprite2d : Sprite2D
@export var armor_1_sprite2d_textures : Array[Texture2D]

@export var arm_1_drop: Node2D


@export_subgroup("二类防具状态")
@export var curr_armor_2_hp_status := 1

@export var armor_second_max_hp := 0
@export var armor_second_curr_hp : int

@export var armor_2_sprite2d : Sprite2D
@export var armor_2_sprite2d_textures : Array[Texture2D]

@export var arm_2_drop: Node2D

#endregion

#region 僵尸移动相关
@export_group("移动相关")
@onready var area2d : Area2D = $Area2D
@onready var _ground : Sprite2D = $Body/_ground
var _previous_ground_global_x:float
enum  WalkingStatus {start, walking, end}
@export var walking_status := WalkingStatus.start
#endregion

@export_group("其他")
## 僵尸攻击射线
@onready var ray_cast_2d: RayCast2D = $RayCast2D

#region 被爆炸炸死相关
@onready var body: Node2D = $Body
@onready var zombie_charred: Node2D = $ZombieCharred
@onready var anim_lib: AnimationPlayer = $ZombieCharred/AnimLib
#endregion

## 僵尸被攻击信号，传递给ZombieManager
signal zombie_damaged(damage: int, wave: int)
## 僵尸被击杀信号，传递给ZombieManager
signal zombie_dead



func _ready() -> void:
	super._ready()
	_previous_ground_global_x = _ground.position.x
	
	armor_first_curr_hp = armor_first_max_hp
	armor_second_curr_hp = armor_second_max_hp
	
	_curr_damage_per_second = damage_per_second

func _process(delta):
	# 每帧检查射线是否碰到植物
	if ray_cast_2d.is_colliding():
		if not is_attack:
			
			var collider = ray_cast_2d.get_collider()
			if collider is Area2D:
			# 获取Area2D的父节点
				_curr_plant = collider.get_parent()
				
			is_walk = false
			walking_status = WalkingStatus.end
			is_attack = true
			
		
	else:
		if is_attack:
			_curr_plant = null
			
			is_attack = false
			is_walk = true
			walking_status = WalkingStatus.start
	
	
func _physics_process(delta: float) -> void:
	if is_walk:
		if walking_status == WalkingStatus.end:
			_previous_ground_global_x = _ground.global_position.x
		elif walking_status == WalkingStatus.start:
			walking_status = WalkingStatus.walking
			_previous_ground_global_x = _ground.global_position.x
		else:
			_walk()
	
	## 如果正在攻击
	if _curr_plant and is_attack:
		## 每4帧扣血一次
		frame_counter += 1
		
		# 每三帧植物掉血一次，被减速每6帧植物掉血一次 
		if is_decelerated:
			if frame_counter % 6 == 0:
				_curr_plant.be_attacked(_curr_damage_per_second * delta * 3)
			
		else:
			if frame_counter % 3 == 0:
				_curr_plant.be_attacked(_curr_damage_per_second * delta * 3)
			
		# 防止过大，每 10000 帧归零（大概每 167 秒）
		if frame_counter >= 10000:
			frame_counter = 0


## 获取当前僵尸所有血量（HP+防具）
func get_zombie_all_hp():
	return max_hp + armor_first_curr_hp + armor_second_curr_hp


#region 僵尸移动相关
func _walking_end():
	walking_status = WalkingStatus.end
	_previous_ground_global_x = _ground.global_position.x


func _walking_start():
	walking_status = WalkingStatus.start
	_previous_ground_global_x = _ground.global_position.x

func _walk():
	# 计算ground的全局坐标变化量
	var ground_global_offset = _ground.global_position.x - _previous_ground_global_x
	# 反向调整zombie的position.x以抵消ground的移动
	self.position.x -= ground_global_offset
	# 更新记录值
	_previous_ground_global_x = _ground.global_position.x
#endregion

#region 僵尸被攻击
## 被子弹攻击
func be_attacked_bullet(attack_value:int, bullet_mode : Global.BulletMode):
	# SFX 根据防具是否有铁器进行判断，防具掉落时修改bool值
	if be_bullet_SFX_is_shield_first or be_bullet_SFX_is_shield_second: 
		get_node("SFX/Bullet/Shieldhit" + str(randi_range(1,2))).play()
	else:
		get_node("SFX/Bullet/Splat" + str(randi_range(1,3))).play()
	
	Hp_loss(attack_value, bullet_mode)
	body_light()
	zombie_damaged.emit(attack_value, curr_wave)

#region 僵尸血量防具改变
## 有二类防具的情况下判断，掉血前二类防具血量大于0
func _judge_status_armor_2():
	# 二类防具第一次血量小于0， 将小于0的血量返回，表示剩余攻击力
	if armor_second_curr_hp <= 0 and curr_armor_2_hp_status < 4:
		curr_armor_2_hp_status = 4
		armor_2_sprite2d.visible = false
		
		## 二类防具音效改变
		be_bullet_SFX_is_shield_second = false
		arm2_drop()
		
		return -armor_second_curr_hp
		
	# 第一次血量小于1/3
	elif armor_second_curr_hp <= armor_second_max_hp / 3 and curr_armor_2_hp_status < 3:
		curr_armor_2_hp_status = 3
		armor_2_sprite2d.texture = armor_2_sprite2d_textures[1]
		
		return 0
	
	# 第一次血量小于2/3
	elif armor_second_curr_hp <= armor_second_max_hp * 2/ 3 and curr_armor_2_hp_status < 2:
		curr_armor_2_hp_status = 2
		armor_2_sprite2d.texture = armor_2_sprite2d_textures[0]
		
		return 0
		
	else:
		return 0

## 二类防具掉落
func arm2_drop():
	arm_2_drop.acitvate_it()
	


## 有一类防具的情况下判断，掉血前一类防具血量大于0
func _judge_status_armor_1():
	# 一类防具第一次血量小于0， 将小于0的血量返回，表示剩余攻击力
	if armor_first_curr_hp <= 0 and curr_armor_1_hp_status < 4:
		curr_armor_1_hp_status = 4
		armor_1_sprite2d.visible = false
		
		## 一类防具音效改变
		be_bullet_SFX_is_shield_first = false
		arm1_drop()
		
		return -armor_first_curr_hp
		
	# 第一次血量小于1/3
	elif armor_first_curr_hp <= armor_first_max_hp / 3 and curr_armor_1_hp_status < 3:
		curr_armor_1_hp_status = 3
		armor_1_sprite2d.texture = armor_1_sprite2d_textures[1]
		
		return 0
	
	# 第一次血量小于2/3
	elif armor_first_curr_hp <= armor_first_max_hp * 2/ 3 and curr_armor_1_hp_status < 2:
		curr_armor_1_hp_status = 2
		armor_1_sprite2d.texture = armor_1_sprite2d_textures[0]

		return 0
		
	else:
		return 0

## 一类防具掉落
func arm1_drop():
	arm_1_drop.acitvate_it()
	

#endregion

#region 僵尸血量改变
# 僵尸被攻击时掉血（包括防具变化）
func Hp_loss(attack_value:int, bullet_mode : Global.BulletMode):
	match bullet_mode:
		## 普通子弹
		Global.BulletMode.Norm:
			# 如果有二类防具，先对二类防具掉血，若二类防具血量<0, 修改
			if armor_second_curr_hp > 0:
				armor_second_curr_hp -= attack_value
				attack_value = _judge_status_armor_2()
				
			# 如果有一类防具
			if armor_first_curr_hp > 0 and attack_value > 0:
				armor_first_curr_hp -= attack_value
				attack_value = _judge_status_armor_1()
			
			# 血量>0
			if curr_Hp > 0 and attack_value > 0:
				curr_Hp -= attack_value
				judge_status()
		# 穿透子弹
		Global.BulletMode.penetration:
			
			# 如果有二类防具，先对二类防具掉血，若二类防具血量<0, 修改
			if armor_second_curr_hp > 0:
				armor_second_curr_hp -= attack_value
				_judge_status_armor_2()
				
			# 如果有一类防具
			if armor_first_curr_hp > 0 and attack_value > 0:
				armor_first_curr_hp -= attack_value
				attack_value = _judge_status_armor_1()
			
			# 血量>0
			if curr_Hp > 0 and attack_value > 0:
				curr_Hp -= attack_value
				judge_status()
				
		Global.BulletMode.real:
				
			# 如果有一类防具
			if armor_first_curr_hp > 0 and attack_value > 0:
				armor_first_curr_hp -= attack_value
				attack_value = _judge_status_armor_1()
			
			# 血量>0
			if curr_Hp > 0 and attack_value > 0:
				curr_Hp -= attack_value
				judge_status()
			
## 血量状态判断
func judge_status():
	if curr_Hp <= max_hp/3 and curr_hp_status < 3:
		curr_hp_status = 3
		is_death = true
		_delete_area2d()	# 删除碰撞器
		_hp_3_stage()
		
	elif curr_Hp <= max_hp*2/3 and curr_hp_status < 2:
		curr_hp_status = 2
		_hp_2_stage()
		
## 第一次血量2阶段变化 掉手状态
func _hp_2_stage():
	_hand_fade()

# 下半胳膊消失
func _hand_fade():
	## 隐藏下半胳膊
	for arm_hand_part in zombie_status_2_fade:
		arm_hand_part.visible = false
	## 掉落下半胳膊
	hand_drop.acitvate_it()
	
	## 修改上半胳膊图片（残血图片）
	zombie_outerarm_upper.texture = zombie_outerarm_upper_sprite2d_textures
	

## 第一次血量3阶段变化 掉头状态
func _hp_3_stage():
	_head_fade()
	
# 头消失，
func _head_fade():
	# SFX 僵尸头掉落
	$SFX/Shoop.play()
	for head_part in zombie_status_3_fade:
		head_part.visible = false
		
	head_drop.acitvate_it()
#endregion
#endregion

## 僵尸啃咬一次，动画中调用,攻击音效
func _attack_once():
	get_node("SFX/Chomp").play()
	_curr_plant.be_attacked_body_light()

#region 僵尸死亡相关
# 删除僵尸
func delete_zombie():
	self.queue_free()


## 僵尸删除area,即僵尸死亡
func _delete_area2d():
	if not area2d_free:
		area2d_free = true
		_curr_damage_per_second = 0
		
		var zombie_all_hp = get_zombie_all_hp()
		zombie_damaged.emit(zombie_all_hp, curr_wave)
		
		zombie_dead.emit(global_position)
		area2d.queue_free()
	
	
## 僵尸被炸死	
func be_bomb_death():
	_delete_area2d()	# 删除碰撞器
	body.visible = false
	animation_tree.active = false
	zombie_charred.visible = true
	# 播放僵尸灰烬动画
	anim_lib.play("ALL_ANIMS")
	await anim_lib.animation_finished
	delete_zombie()


## 僵尸被大嘴花吃掉
func be_chomper_death():
	_delete_area2d()	# 删除碰撞器
	delete_zombie()


## 僵尸死亡后逐渐透明，最后删除节点
func _fade_and_remove():
	var tween = create_tween()  # 自动创建并绑定Tween节点
	tween.tween_property(self, "modulate:a", 0.0, 1.0)  # 1秒内透明度降为0
	tween.tween_callback(delete_zombie)  # 动画完成后删除僵尸

#endregion
	
