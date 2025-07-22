extends CherryBomb
class_name PotatoMine


@onready var ray_cast_2d: RayCast2D = $RayCast2D

@export_group("土豆雷基础")
@export var bury_time = 10
# 爆炸检测碰撞体

@export_group("动画状态")
@export var is_armed := false
@export var is_start_rise := false

func _ready() -> void:
	super._ready()
	
	_start_rise_timer()
	## 继承樱桃炸弹，已经设置不眨眼

## 播放音效
func play_bome_sfx():
	## 播放音效
	SoundManager.play_plant_SFX(Global.PlantType.PotatoMine, &"PotatoMine")
	
	
func _start_rise_timer() -> void:
	await get_tree().create_timer(bury_time).timeout
	
	if is_instance_valid(self):
		is_start_rise = true  # 开始冒出（触发 rise 动画）

func _rise_end():
	is_armed = true
	is_bomb = false
	
	## 开始眨眼
	is_blink = true
	blink_timer.start()

func _process(delta):
	if is_armed:
		# 每帧检查射线是否碰到僵尸
		var collider = ray_cast_2d.get_collider()
		if collider != null:  # 必须检查是否为null
			is_bomb = true
			await get_tree().physics_frame    # 等待碰撞层更新生效
			_bomb_all_area_zombie()

func _bomb_all_area_zombie():
	if not is_bomb_end:
		is_bomb_end = true
		var areas = area_2d_2.get_overlapping_areas()
		for area in areas:
			area.get_parent().disappear_death()
		
		_bomb_particle()

func judge_death_bomb(plant:PlantBase):
	if not is_bomb_end:
		is_bomb_end = true
		if is_armed:
			_bomb_all_area_zombie()
