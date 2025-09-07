extends Zombie000Base
class_name Zombie014Bobsled

@onready var zombie_bobsled_1: Sprite2D = $ZombieBobsled1
@onready var judge_is_in_ice_road_timer: Timer = $JudgeIsInIceRoadTimer

@onready var all_zombie_bobsled_single_body :Array[BodyCharacter]= [
	$Body,
	$Body2,
	$Body3,
	$Body4
]
@onready var all_anim_player:Array[AnimationPlayer] = [
	$Body/AnimationPlayer,
	$Body2/AnimationPlayer,
	$Body3/AnimationPlayer,
	$Body4/AnimationPlayer,
]

func init_norm():
	super()
	judge_is_in_ice_road_timer.start()
	_play_anim("Zombie_bobsled_push")
	await get_tree().create_timer(4.0, false).timeout
	_play_anim("Zombie_bobsled_jump")
	move_component.change_move_mode(MoveComponent.E_MoveMode.Speed)

## 初始化展示角色
func init_show():
	super()
	_play_anim("Zombie_bobsled_idle")

## 播放动画
func _play_anim(anim_name:StringName):
	for anim_player in all_anim_player:
		anim_player.play(anim_name)

## 判断冰道是否在冰道上(0.3秒检测一次,不在冰道上掉100血)
func judge_is_in_ice_road():
	var is_in_road = false
	for ice_road:IceRoad in MainGameDate.all_ice_roads[lane]:
		## 如果冰道最左边 < 当前位置+偏移
		if ice_road.left_x < global_position.x - 50:
			is_in_road = true
			break
	if not is_in_road:
		hp_component.Hp_loss(100, Global.AttackMode.Real, false)


## 角色死亡
func character_death():
	super()
	for zombie_bobsled_single_body in all_zombie_bobsled_single_body:
		zombie_bobsled_single_body.visible = false
	await get_tree().create_timer(1, false).timeout
	var tween :Tween= create_tween()
	tween.tween_property(zombie_bobsled_1, "modulate:a", 0, 1)
	tween.tween_callback(queue_free)

## 亡语
func death_language():
	if is_can_death_language:
		var zombie_row:ZombieRow = get_parent()
		for sub_zombie_body in all_zombie_bobsled_single_body:
			## 僵尸相对本体父节点的x
			var zombie_pos_x = sub_zombie_body.global_position.x - zombie_row.zombie_create_position.global_position.x
			MainGameDate.zombie_manager.call_deferred(
				"create_norm_zombie",
				Global.ZombieType.ZombieBobsledSingle,
				zombie_row,
				Character000Base.E_CharacterInitType.IsNorm,
				lane,
				curr_wave,
				Vector2(zombie_pos_x, position.y)
			)

## 调整雪橇车和僵尸的显示顺序
func update_bobsled_order():
	move_child(zombie_bobsled_1, -1)

	for zombie_bobsled_single_body in all_zombie_bobsled_single_body:
		var tween :Tween= create_tween()
		tween.tween_property(zombie_bobsled_single_body, ^"position:y", zombie_bobsled_single_body.position.y-10, 1)
