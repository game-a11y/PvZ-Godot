extends Node2D
class_name HandManager

@onready var main_game: MainGameManager = $"../.."

var card_list:Array[Card]

## 卡片和铲子
@onready var shovel_real: Sprite2D = $Shovel		# 真实铲子

@onready var card_manager: CardManager = $"../../Camera2D/CardManager"

## 植物临时挂载节点
@onready var temporary_plants: Node = $"../../TemporaryPlants"

@export var curr_card:Card
@export var new_plant_static:Node2D
@export var new_plant_static_shadow:Node2D
@export var new_plant_condition:ResourcePlantCondition

@onready var plant_cells: Node2D = $"../../PlantCells"
var plant_cells_array: Array	# 二维数组，保存每个植物格子节点

## 当前鼠标所在植物格子
var curr_plant_cell:PlantCell

var new_plant_static_in_cell := false	# 植物是否在cell中
## 手上是否拿铲子
@export var is_shovel:bool = false
## 当前铲子选择植物
@export var plant_be_shovel_look:PlantBase
## 当前铲子所在格子植物数量
var curr_shovel_look_plant_num:int = 0

## 格子中有多个植物时，判断新预铲除植物是否一致
var new_plant_be_shovel_look :PlantBase

## 柱子模式 
var new_plant_static_shadow_colum : Array 

## 植物种植泥土粒子特效
const PlantStartEffectScene = preload("res://scenes/character/plant/plant_start_effect.tscn")
## 植物种植水池粒子特效
const PlantStartEffectWaterScene = preload("res://scenes/character/plant/plant_start_effect_water.tscn")

## 墓碑场景，黑夜关卡加载
const tombstone_scenes:PackedScene =  preload("res://scenes/item/game_scenes_item/tombstone.tscn")

var is_tombstone := []
var tombstone_num := 0
## 生成的墓碑列表
var tombstone_list :Array[TombStone]
## 种植的植物
var curr_plants :Array[PlantBase]= []
## 铲子快捷键信号
signal shortcut_keys_shovel_F



func init_plant_cells():
	# 植物种植区域信号，更新植物位置列号
	for plant_cells_row_i in plant_cells.get_child_count():
		## 某一行plant_cells
		var plant_cells_row = plant_cells.get_child(plant_cells_row_i)
		
		# 创建这一行的是否有墓碑的数组
		var is_tombstone_row := []
		for plant_cells_col_j in plant_cells_row.get_child_count():
			
			var plant_cell:PlantCell = plant_cells_row.get_child(plant_cells_col_j)
			plant_cell.click_cell.connect(_on_click_cell)
			plant_cell.cell_mouse_enter.connect(_on_cell_mouse_enter)
			plant_cell.cell_mouse_exit.connect(_on_cell_mouse_exit)
			plant_cell.row_col = Vector2(plant_cells_row_i, plant_cells_col_j)
			## 该位置没有墓碑
			is_tombstone_row.append(false)
			
		plant_cells_array.append(plant_cells_row.get_children())
		
		is_tombstone.append(is_tombstone_row)
	
## 保龄球模式下，只能种左边
func minigame_bowling_del_right_plant_cells():
	for plant_cells_row:Array in plant_cells_array:
		for i in range(plant_cells_row.size()):  # 遍历
			## 顺序是从右往左，删除右边信号，保留3列
			if i < 6:
				plant_cells_row[i].click_cell.disconnect(_on_click_cell)
				plant_cells_row[i].cell_mouse_enter.disconnect(_on_cell_mouse_enter)
				plant_cells_row[i].cell_mouse_exit.disconnect(_on_cell_mouse_exit)
				
## 卡片和铲子信号连接
func card_game_signal_connect(cards:Array[Card], shovel_bg):
	for card in cards:
		if card:
			card.card_click.connect(_manage_new_plant_static)
	# 铲子
	shovel_bg.shovel_click.connect(_manage_shovel)
	## 连接快捷键信号
	shortcut_keys_shovel_F.connect(_pressed_shortcut_keys_shovel_F)
	
## 一张卡片信号连接，传送带使用
func one_card_game_signal_connect(card:Card):
	card.card_click.connect(_manage_new_plant_static)


func _process(delta: float) -> void:
	if curr_card:
		new_plant_static.global_position = get_global_mouse_position()

	if is_shovel:
		shovel_real.global_position = get_global_mouse_position()
		## 如果有预铲植物并且当前格子有多个植物时
		if plant_be_shovel_look and curr_shovel_look_plant_num >= 2:
			print("当前卡槽有多个植物")
			new_plant_be_shovel_look = curr_plant_cell.return_plant_be_shovel_look()
			if new_plant_be_shovel_look == plant_be_shovel_look:
				pass
			else:
				plant_be_shovel_look.be_shovel_look_end()
				plant_be_shovel_look = new_plant_be_shovel_look
				plant_be_shovel_look.be_shovel_look()

# 点击卡片
func _manage_new_plant_static(card:Card) -> void:
	SoundManager.play_other_SFX("seedlift")
	
	if not curr_card:
		## 如果有铲子
		if is_shovel:
				SoundManager.play_other_SFX("tap2")
				if plant_be_shovel_look:
					plant_be_shovel_look.be_shovel_look_end()
					plant_be_shovel_look = null
				_cance_shovel_or_end()
				
		self.curr_card = card
		new_plant_condition = Global.get_plant_info(curr_card.card_type, Global.PlantInfoAttribute.PlantConditionResource)
		new_plant_static = Global.get_plant_info(curr_card.card_type, Global.PlantInfoAttribute.PlantStaticScenes).instantiate()
		new_plant_static.scale = Vector2.ONE
		new_plant_static_shadow = new_plant_static.duplicate()
		new_plant_static_shadow.modulate.a = 0
		new_plant_static.z_index = 1
		
		temporary_plants.add_child(new_plant_static_shadow)
		temporary_plants.add_child(new_plant_static)
		
		# 如果是柱子模式
		if main_game.mode_column:
			for i in len(plant_cells_array):
				var new_node = new_plant_static_shadow.duplicate()
				new_plant_static_shadow.get_parent().add_child(new_node)
				new_node.modulate.a = 0
				new_plant_static_shadow_colum.append(new_node)
		

# 点击铲子
func _manage_shovel() -> void:
	if not is_shovel:
		SoundManager.play_other_SFX("shovel")
		is_shovel = true
		shovel_real.visible = true
		card_manager.shovel_ui.visible = false

# 点击种植或铲掉植物
func _on_click_cell(plant_cell:PlantCell):

	if new_plant_static_in_cell and curr_card:
		# 创建植物
		_create_new_plant(curr_card.card_type, plant_cell)
		## 卡片种植完成后发射信号
		curr_card.card_plant_end.emit(curr_card)
		
		new_plant_static_in_cell = false
		_cancel_plant_or_end()
		
		
	# 手拿铲子并且当前存在被铲子威胁的植物
	if is_shovel and plant_be_shovel_look:
		SoundManager.play_other_SFX("plant2")
		_cance_shovel_or_end()
		plant_be_shovel_look.be_shovel_kill()

func _create_new_plant(plant_type:Global.PlantType, plant_cell:PlantCell):
	# 创建植物
	var new_plant :PlantBase= Global.get_plant_info(plant_type, Global.PlantInfoAttribute.PlantScenes).instantiate()
	
	new_plant.plant_free_signal.connect(_one_plant_free)
	new_plant.plant_free_signal.connect(plant_cell.one_plant_free)
	
	plant_cell.add_plant(new_plant)
	curr_plants.append(new_plant)
	
	
	var plant_start_effect_scene:Node2D
	## 当前地形为水或者睡莲
	if plant_cell.curr_condition & 8 or plant_cell.curr_condition & 16:
		plant_start_effect_scene = PlantStartEffectWaterScene.instantiate()
	else:
		plant_start_effect_scene = PlantStartEffectScene.instantiate()

	new_plant.add_child(plant_start_effect_scene)
	

	return new_plant
	
func _one_plant_free(plant:PlantBase):
	curr_plants.erase(plant)
	
	
# 鼠标进入cell
func _on_cell_mouse_enter(plant_cell:PlantCell):
	curr_plant_cell = plant_cell
	## 静态植物比当前植物种植条件慢一帧消除
	if  curr_card:
		## 如果是普通植物并且当前格子可以种植普通植物
		if not new_plant_condition.is_special_plants and plant_cell.can_common_plant:
			
			## 如果地形当前格子地形符合 并且 当前格子对应的植物位置为空
			if new_plant_condition.plant_condition & plant_cell.curr_condition and plant_cell.plant_in_cell[new_plant_condition.place_plant_in_cell] == null:
				new_plant_static_in_cell = true
				new_plant_static_shadow.global_position = plant_cell.get_new_plant_static_shadow_global_position(new_plant_condition.place_plant_in_cell)
				
				new_plant_static_shadow.modulate.a = 0.5
				
			else:
				new_plant_static_shadow.modulate.a = 0
				new_plant_static_in_cell = false

		## 如果是特殊植物，特殊植物调用自己的方法判断是否可以种植
		elif new_plant_condition.is_special_plants:
			if new_plant_condition.judge_special_plants_condition(plant_cell):
				new_plant_static_in_cell = true
				new_plant_static_shadow.global_position = plant_cell.get_new_plant_static_shadow_global_position(new_plant_condition.place_plant_in_cell)
				new_plant_static_shadow.modulate.a = 0.5
				
			else:
				new_plant_static_shadow.modulate.a = 0
				new_plant_static_in_cell = false
		## 如果都不是，不能种植
		else:
			new_plant_static_shadow.modulate.a = 0
			new_plant_static_in_cell = false

	# 如果手拿铲子
	if is_shovel:
		## 获取当前格子植物数量
		curr_shovel_look_plant_num = plant_cell.get_curr_plant_num()
		if curr_shovel_look_plant_num >= 1:
			plant_be_shovel_look =  plant_cell.return_plant_be_shovel_look()
			plant_be_shovel_look.be_shovel_look()
		


# 鼠标移出cell
func _on_cell_mouse_exit(plant_cell:PlantCell):
	curr_plant_cell = null
	if curr_card:
		if main_game.mode_column:
			# 当前cell的列
			#对每一行new_node变量，获取当前new_plant_static_shadow_colum的所有new_node
			for new_node in new_plant_static_shadow_colum:
				new_node.modulate.a = 0
				new_plant_static_in_cell = false
				
		else:
			new_plant_static_shadow.modulate.a = 0
			new_plant_static_in_cell = false
		
	# 如果手拿铲子
	if is_shovel and plant_be_shovel_look:
		plant_be_shovel_look.be_shovel_look_end()
		plant_be_shovel_look = null

## 铲子快捷键
func _pressed_shortcut_keys_shovel_F():
	## 如果手上有植物
	if  curr_card:
		SoundManager.play_other_SFX("tap2")
		_cancel_plant_or_end()
	## 如果手上有铲子
	if is_shovel:
		SoundManager.play_other_SFX("tap2")
		if plant_be_shovel_look:
			plant_be_shovel_look.be_shovel_look_end()
			plant_be_shovel_look = null
		_cance_shovel_or_end()
	## 点击铲子函数
	_manage_shovel()
	## 如果当前在植物格子中
	if curr_plant_cell:
		_on_cell_mouse_enter(curr_plant_cell)
		
# 右键点击
func _input(event):
	## 铲子快捷键
	if Input.is_action_just_pressed("Shovel_F"):
		shortcut_keys_shovel_F.emit()

	if event is InputEventMouseButton:
		if curr_card:
			#右键点击
			if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				SoundManager.play_other_SFX("tap2")
				_cancel_plant_or_end()

			#左键点击空白
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not new_plant_static_in_cell:
				SoundManager.play_other_SFX("tap2")
				_cancel_plant_or_end()
		
		if is_shovel:
			#右键点击
			if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				SoundManager.play_other_SFX("tap2")
				if plant_be_shovel_look:
					plant_be_shovel_look.be_shovel_look_end()
					plant_be_shovel_look = null
				_cance_shovel_or_end()
			
			#左键点击空白
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not plant_be_shovel_look:
				SoundManager.play_other_SFX("tap2")
				_cance_shovel_or_end()
		

# 取消种植或者种植完成后
func _cancel_plant_or_end():
	curr_card = null
	new_plant_condition = null
	new_plant_static.queue_free()
	new_plant_static_shadow.queue_free()
	
	# 如果是柱子模式
	if main_game.mode_column:
		for new_node in new_plant_static_shadow_colum:
			new_node.queue_free()
		new_plant_static_shadow_colum.clear()
		
# 取消铲子或者铲子完成后
func _cance_shovel_or_end():
	is_shovel = false
	shovel_real.visible = false
	card_manager.shovel_ui.visible = true
	
	
#region 墓碑相关

## 生成待选位置,没有墓碑的行和列
func _candidates_position(rows:int, cols_end:int, cols_start:int=0) -> Array[Vector2i]:
	# 构建可选位置列表
	var candidates: Array[Vector2i]= []
	for r in range(rows):
		for c in range(cols_start, cols_end):
			## 如果没有墓碑
			if not is_tombstone[r][c]:
				candidates.append(Vector2i(r, c))
				
	# 打乱顺序确保随机性
	candidates.shuffle()
	return candidates
	
## 随机生成墓碑的位置
func _reandom_tombstone_pos(new_num:int) ->  Array[Vector2i]:
	var rows = len(plant_cells_array)
	var cols = len(plant_cells_array[0])
		
	# 如果请求的数量超过所有格子总数，就返回所有格子
	if new_num + tombstone_num >= rows * cols:
		var all_positions = _candidates_position(rows, cols)
		return all_positions
		
	var usable_cols : int
	## 当场上墓碑数量小于 6列 * 行数时
	if tombstone_num < 6 * rows:
		usable_cols = 6 
	else:
		usable_cols = cols
	
	# 构建可选位置列表
	var candidates = _candidates_position(rows, usable_cols)
	
	# 取前n个作为随机选择位置
	var selected_positions = candidates.slice(0, min(new_num, candidates.size()))
	
	if len(selected_positions) < new_num:
		# 构建可选位置列表
		var new_candidates = _candidates_position(rows, cols, usable_cols)
		var add_pos = new_candidates.slice(0, min(new_num- len(selected_positions), new_candidates.size()))
		
		selected_positions.append_array(add_pos)
	
	return selected_positions

## 创建一个墓碑
func _create_one_tombstone(plant_cell: PlantCell, pos:Vector2i):
	assert(not plant_cell.is_tombstone and not is_tombstone[plant_cell.row_col.x][plant_cell.row_col.y])
	var tombstone :Node2D= tombstone_scenes.instantiate()
	
	## plant_cell生成墓碑并连接信号
	plant_cell.create_tombstone(tombstone)
	plant_cell.cell_delete_tombstone.connect(_delete_tombstone)
	
	# 创建墓碑相关参数变化
	is_tombstone[pos.x][pos.y] = true
	tombstone_num += 1
	
	tombstone_list.append(tombstone)

	
## 删除墓碑修改对应的参数并断开信号连接
func _delete_tombstone(plant_cell:PlantCell, tombstone:TombStone):
	plant_cell.cell_delete_tombstone.disconnect(_delete_tombstone)
	
	var pos:Vector2i = plant_cell.row_col
	is_tombstone[pos.x][pos.y] = false
	tombstone_num -= 1
	tombstone_list.erase(tombstone)

## 黑夜关卡生成墓碑（生成数量）
func create_tombstone(new_num:int):
	## 最大数量： 最大可生成列数 * 行数
	## 生成随机位置
	var selected_positions :Array[Vector2i]= _reandom_tombstone_pos(new_num)
	for pos in selected_positions:
		var plant_cell:PlantCell = plant_cells_array[pos.x][pos.y]
		## 如果存在植物
		if plant_cell.plant_in_cell[Global.PlacePlantInCell.Norm]:
			plant_cell.plant_in_cell[Global.PlacePlantInCell.Norm]._plant_free()
			
		## 如果存在植物
		if plant_cell.plant_in_cell[Global.PlacePlantInCell.Down]:
			plant_cell.plant_in_cell[Global.PlacePlantInCell.Down]._plant_free()
			
		## 如果存在植物
		if plant_cell.plant_in_cell[Global.PlacePlantInCell.Shell]:
			plant_cell.plant_in_cell[Global.PlacePlantInCell.Shell]._plant_free()
			
		_create_one_tombstone(plant_cell, pos)


#endregion


#region UI血量相关
## 显示植物血量
func display_plant_HP_label():
	if Global.display_plant_HP_label:
		for plant in curr_plants:
			plant.label_hp.visible = true
	else:
		for plant in curr_plants:
			plant.label_hp.visible = false

#endregion
