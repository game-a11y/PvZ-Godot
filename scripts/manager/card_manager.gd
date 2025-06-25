extends Control
class_name CardManager

## 主游戏场景
@onready var main_game: MainGameManager = $"../.."

@onready var grid_container: GridContainer = $CardChooser/TextureRect/GridContainer
@onready var card_chooser: Control = $CardChooser
@onready var card_bar_and_shovel: Control = $CardBarAndShovel


@onready var card_ui_list: HBoxContainer = $CardBarAndShovel/CardBarBg/CardUiList
@onready var temporary_card: Control = $TemporaryCard
@onready var shovel_bg: TextureRect = $CardBarAndShovel/MarginContainer/ShovelBg
@onready var shovel_ui: TextureRect = $CardBarAndShovel/MarginContainer/ShovelBg/Shovel

var current_tween_id := {}

@export_group("卡槽相关")
@export var cards_in_chooser : Array[CardInSeedChooser] = []
## 选择卡片
@export var cards : Array[Card] = []
## 卡槽占位节点
@export var cards_placeholder:Array = []
@onready var card_placeholder_ori: TextureRect = $CardBarAndShovel/CardBarBg/CardUiList/CardPlaceholder_ori


#region 阳光相关
@export_group("阳光")
@export var start_sun : int
@onready var curr_sun_value: Label = $CardBarAndShovel/CardBarBg/SunLabelControl/CurrSunValue

var sun: 
	get:
		return sun
	set(value):
		sun = value
		curr_sun_value.text = str(value)
		for card in cards:
			card.judge_sun_enough(value)
#endregion


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sun = start_sun

## 测试场景直接对卡片获取卡片列表
func test_scenes_init_cards():
	for card_placeholder in card_ui_list.get_children():
		cards.append(card_placeholder.get_node("Card"))

	
## 初始化出战卡槽
func init_card_bar():
	for i in range(main_game.max_choosed_card_num):
		var cloned_card_placeholder = card_placeholder_ori.duplicate()
		card_ui_list.add_child(cloned_card_placeholder)
		
	card_placeholder_ori.free()	## 立即删除掉该节点，下面获取卡槽占位节点
	cards_placeholder = card_ui_list.get_children()

## 是否显示多余卡槽
func judge_disappear_add_card_bar():
	if Global.disappear_spare_card_Placeholder:
		if len(cards) < main_game.max_choosed_card_num:
			for i in range(len(cards),main_game.max_choosed_card_num):
				cards_placeholder[i].visible = false
	else:
		for i in range(main_game.max_choosed_card_num):
			cards_placeholder[i].visible = true
			
## 根据Global文件初始化生成待选卡片
func init_CardChooser():
	# 加载场景文件
	var card_chooser_placeholder = grid_container.get_children()

	for i in Global.curr_plant:
		var card_in_seed_chooser: CardInSeedChooser = Global.card_in_seed_chooser.instantiate()
		card_chooser_placeholder[i].add_child(card_in_seed_chooser)
		card_in_seed_chooser.card_init(i)
		card_in_seed_chooser.card.card_click.connect(_on_card_click)

		cards_in_chooser.append(card_in_seed_chooser) 

## 游戏选卡阶段时，卡片被点击
func _on_card_click(card:Card):
	# 如果card被选择，取消选取，后面的card向前移动
	if card.is_choosed:
		card.is_choosed = false
		var card_idx = cards.find(card)
		cards.erase(card)
		for i in range(card_idx, len(cards)):
			move_card_to(cards[i], cards_placeholder[i])
		move_card_to(card, card.card_in_seed_chooser)
	
	# 如果没被选取，放在最后一位
	else:
		if len(cards) >= main_game.max_choosed_card_num:
			SoundManager.play_sfx("Card/Error")
			return
		else:
			card.is_choosed = true
			cards.append(card)
			move_card_to(card, cards_placeholder[len(cards)-1])
	
## 移动card到目标点位置
func move_card_to(card:Card, target_parent):
	if not current_tween_id.has(card.card_type):
		current_tween_id[card.card_type] = 0  # 初始化为默认值
	# 每点击一次，生成一个新的唯一ID
	current_tween_id[card.card_type] += 1
	var this_tween_id = current_tween_id[card.card_type]
	
	var ori_global_position = card.global_position
	card.get_parent().remove_child(card)
	temporary_card.add_child(card)
	card.global_position = ori_global_position
	
	var tween = create_tween()
	tween.tween_property(card, "global_position", target_parent.global_position, 0.2) # 时间可以改短点
	
		# 用信号方式处理 tween 结束（防止 await 被打断）
	tween.connect("finished", func():

		# 只执行“最后一次点击”的 tween 的回调
		if this_tween_id != current_tween_id[card.card_type]:
			return  # 当前 tween 已被弃用

		if is_instance_valid(card):
			card.get_parent().remove_child(card)
			target_parent.add_child(card)
			card.position = Vector2.ZERO
	)

## 卡片断开连接，游戏开始后修改点击信号连接
func card_disconnect_card():
	for card in cards:
		card.card_click.disconnect(_on_card_click)


## 移动卡槽（出现或隐藏）
func move_card_chooser(is_appeal:bool):
	var tween = create_tween()
	if is_appeal:
		tween.tween_property(card_chooser, "position",Vector2(0, 89.0), 0.2) # 时间可以改短点
	else:
		tween.tween_property(card_chooser, "position",Vector2(0, 615.0), 0.2) # 时间可以改短点
	
	await tween.finished

## 移动待选卡槽（出现或隐藏）
func move_card_bar(is_appeal:bool):
	var tween = create_tween()
	if is_appeal:
		tween.tween_property(card_bar_and_shovel, "position",Vector2(13, 0), 0.2) # 时间可以改短点
	else:
		tween.tween_property(card_bar_and_shovel, "position",Vector2(13, 100.0), 0.2) # 时间可以改短点
	
	await tween.finished
	
