extends PanelContainer
## 出战卡槽
class_name CardSlotBattle

@onready var curr_sun_value: Label = $SunLabelControl/CurrSunValue
@onready var card_placeholder_ori: TextureRect = $CardUiList/CardPlaceholder_ori
@onready var card_ui_list: HBoxContainer = $CardUiList

## 出战卡槽占位节点
var cards_placeholder:Array = []
## 出战卡片
var curr_cards : Array[Card]
## 阳光值
var sun_value:
	set(value):
		sun_value = value
		curr_sun_value.text = str(value)

		for card in curr_cards:
			card.judge_sun_enough(value)

func _ready() -> void:
	Global.signal_change_disappear_spare_card_placeholder.connect(judge_disappear_add_card_bar)
	EventBus.subscribe("test_change_sun_value", func(value): sun_value = value)
	EventBus.subscribe("add_sun_value", func(value): sun_value+=value)

## 初始化出战卡槽，管理器调用
func init_card_slot_battle(max_choosed_card_num:int, sun:int):
	self.sun_value = sun
	for i in range(max_choosed_card_num):
		var cloned_card_placeholder = card_placeholder_ori.duplicate()
		card_ui_list.add_child(cloned_card_placeholder)

	card_placeholder_ori.free()		## 立即删除掉该节点，下面获取卡槽占位节点
	cards_placeholder = card_ui_list.get_children()
	return cards_placeholder

## 主游戏刷新卡片
func main_game_refresh_card():
	for i in range(curr_cards.size()):
		var card:Card = curr_cards[i]
		card.judge_sun_enough(sun_value)
		card.signal_card_use_end.connect(card_use_end.bind(card))
		card.set_shortcut((i+1)%10)

## 卡片种植后信号调用函数
func card_use_end(card:Card):
	## 减少阳光，卡片冷却
	sun_value = sun_value - card.sun_cost
	card.card_cool()

#region 控制台相关
## 是否显示多余卡槽
func judge_disappear_add_card_bar():
	## 在游戏进行阶段
	if MainGameDate.main_game_progress == MainGameManager.E_MainGameProgress.MAIN_GAME:
		if Global.disappear_spare_card_Placeholder:
			if curr_cards.size() < cards_placeholder.size():
				for i in range(curr_cards.size(), cards_placeholder.size()):
					cards_placeholder[i].visible = false
		else:
			for i in range(cards_placeholder.size()):
				cards_placeholder[i].visible = true
#endregion
