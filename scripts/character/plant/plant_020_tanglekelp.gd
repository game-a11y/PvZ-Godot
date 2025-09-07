extends Plant000Base
class_name Plant020Tanglekelp

@onready var grap_component: GrapComponent = $GrapComponent
@onready var attack_ray_component: AttackRayComponentSquash = $AttackRayComponent


func init_norm_signal_connect():
	super()
	attack_ray_component.signal_can_attack.connect(start_grap_zombie)

## 开始攻击
func start_grap_zombie():
	grap_in_pool(attack_ray_component.enemy_can_be_attacked)
	blink_component.disable_component(ComponentBase.E_IsEnableFactor.Attack)

## 拖入水中
func grap_in_pool(target_zombie:Zombie000Base):
	grap_component.activate_it_to_grap_zombie(target_zombie)
	await get_tree().create_timer(0.3).timeout
	# 水花
	var splash:Splash = SceneRegistry.SPLASH.instantiate()
	plant_cell.add_child(splash)
	splash.global_position = global_position + Vector2(0, 10)

	var tween:Tween = create_tween()
	tween.tween_property(self, "position", position + Vector2(0, 10), 0.5)
	await tween.finished

	character_death()

