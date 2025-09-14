extends Plant000Base
class_name Plant028Blover

## 三叶草吹的时间
@export var blover_time:float = 2.0

var is_blow_away_once:=false

func init_norm():
	super()
	await get_tree().create_timer(blover_time).timeout
	hp_component.Hp_loss_death()

## 吹散迷雾
func blow_away_fog():
	if is_blow_away_once:
		return
	is_blow_away_once = true
	if is_instance_valid(MainGameDate.fog_node):
		MainGameDate.fog_node.be_flow_away()

	EventBus.push_event("blover_blow_away_in_sky_zombie")

