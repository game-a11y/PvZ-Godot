extends ComponentBase
class_name DropItemComponent
## 掉落战利品组件,可以掉落金币\硬币\钻石\花园植物

@export_group("掉落相关")
## 可以掉落坐标X范围,若x在该范围内可以掉落
@export var can_drop_x_range :Vector2 = Vector2(0, 900)
## 掉落金币的概率
@export var drop_coin_rate := 0.3
## 掉落银币、金币、钻石的比例（要求和为1）
@export var drop_coin_silver_glod_diamond_rate := [0.5,0.4,0.1]
## 掉落花园植物概率
@export var drop_garden_plant_rate := 0.004

#region 僵尸掉落
## 掉落金银钻
func drop_coin():
	if global_position.x > can_drop_x_range.y or global_position.x < can_drop_x_range.x:
		return

	var r = randf()
	if r < drop_coin_rate:
		Global.create_coin(drop_coin_silver_glod_diamond_rate,\
		Vector2(clamp(global_position.x, 0, get_viewport().get_visible_rect().size.x),\
		clamp(global_position.y-100, 0, get_viewport().get_visible_rect().size.y)))

## 掉落花园植物
func drop_garden_plant():
	var r = randf()
	if r < drop_garden_plant_rate:
		Global.create_garden_plant(
			Vector2(clamp(global_position.x, 0, get_viewport().get_visible_rect().size.x),\
			clamp(global_position.y-50, 0, get_viewport().get_visible_rect().size.y)))

#endregion

