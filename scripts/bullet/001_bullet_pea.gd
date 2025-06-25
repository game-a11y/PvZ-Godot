extends Node2D
class_name BulletPea


@export var is_attack := false		# 是否已攻击

@export var attack_value := 20			# 子弹伤害
@export var speed: float = 400.0		# 子弹默认移动速度
@export var direction: Vector2 = Vector2.RIGHT	# 子弹默认移动方向

@export var bullet_mode : Global.BulletMode

@export var bullet_effect: BulletEffect

## 子弹移动离出生点最大距离
@export var max_distance := 2000.0
## 子弹初始位置
var start_pos: Vector2

## 超出屏幕500像素删除
var screen_rect: Rect2 

func _ready() -> void:
	# 必须在 ready 后才能安全获取视口尺寸
	screen_rect = get_viewport_rect().grow(500)
	# 安全获取BulletEffect节点并验证类型
	if has_node("BulletEffect"):
		var effect_node = $BulletEffect
		bullet_effect = effect_node

	else:
		# 可以选择禁用子弹效果或使用默认值
		bullet_effect = null
	
func _process(delta: float) -> void:
	# 每帧移动子弹
	position += direction * speed * delta
	
		# 新增：移动超过250像素后销毁
	if global_position.distance_to(start_pos) > max_distance:
		queue_free()

	
	if not screen_rect.has_point(global_position):
		queue_free()
		

func _on_area_2d_area_entered(area: Area2D) -> void:
	if not is_attack:
		is_attack = true
		var zombie :ZombieBase = area.get_parent()
		_attack_zombie(zombie)
		if bullet_effect:
			bullet_effect_change_parent(bullet_effect)
			bullet_effect.activate_bullet_effect()
		queue_free()


func _attack_zombie(zombie:ZombieBase):
	#被攻击
	zombie.be_attacked_bullet(attack_value, bullet_mode)



# 更换节点父节点
func bullet_effect_change_parent(bullet_effect:Node2D):
	# 保存全局变换
	var global_transform = bullet_effect.global_transform

	# 移除并添加到bullet节点
	bullet_effect.get_parent().remove_child(bullet_effect)
	get_parent().add_child(bullet_effect)

	# 恢复全局变换，保持位置不变
	bullet_effect.global_transform = global_transform
