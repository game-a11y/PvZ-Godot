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

@onready var plant_cells: Node2D = $"../../PlantCells"
@onready var plant_cells_array: Array

var new_plant_static_in_cell := false	# 植物是否在cell中
## 手上是否拿铲子
@export var is_shovel:bool = false
## 当前铲子选择植物
@export var plant_be_shovel_look:PlantBase

## 柱子模式 
var new_plant_static_shadow_colum : Array 

## 植物种植泥土粒子特效
const PlantStartEffectScene = preload("res://scenes/character/plant/plant_start_effect.tscn")


## 墓碑场景，黑夜关卡加载
var tombstone_scenes:PackedScene
var is_tombstone := []
var tombstone_num := 0

## 种植的植物
var curr_plants :Array[PlantBase]= []


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
		
func init_tombstone_scenes():
	## 墓碑场景
	tombstone_scenes = load("res://scenes/Tombstone/tombstone.tscn")
	

## 卡片和铲子信号连接
func card_game_signal_connect(cards:Array[Card], shovel_bg):
	for card in cards:
		card.card_click.connect(_manage_new_plant_static)
	# 铲子
	shovel_bg.shovel_click.connect(_manage_shovel)
	

func _process(delta: float) -> void:
	if new_plant_static:
		new_plant_static.global_position = get_global_mouse_position()

	if is_shovel:
		shovel_real.global_position = get_global_mouse_position()
		

# 点击卡片
func _manage_new_plant_static(curr_card:Card) -> void:
	SoundManager.play_sfx("Card/Choose")
	if not new_plant_static:
		self.curr_card = curr_card

		new_plant_static = Global.StaticPlantTypeSceneMap.get(curr_card.card_type).instantiate()
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
		SoundManager.play_sfx("Card/Shovel")
		is_shovel = true
		shovel_real.visible = true
		card_manager.shovel_ui.visible = false

# 点击种植或铲掉植物
func _on_click_cell(plant_cell:PlantCell):
	if new_plant_static and not plant_cell.is_plant and not plant_cell.is_tombstone:
		
		SoundManager.play_sfx("PlantCreate/Plant1")
		
		if main_game.mode_column:
			for i in len(plant_cells_array):
				var plant_cell_row_col:PlantCell = plant_cells_array[i][plant_cell.row_col.y]
				## 如果当前cell已有植物
				if plant_cell_row_col.is_plant:
					continue
				# 创建植物
				_create_new_plant(curr_card.card_type, plant_cell_row_col)
		
				
		else:
			# 创建植物
			_create_new_plant(curr_card.card_type, plant_cell)
		
		
		# 减少阳光，卡片冷却
		card_manager.sun = card_manager.sun - curr_card.sun_cost
		curr_card.card_cool()
		
		new_plant_static_in_cell = false
		_cancel_plant_or_end()
		
	# 手拿铲子并且当前存在被铲子威胁的植物
	if is_shovel and plant_be_shovel_look:
		SoundManager.play_sfx("PlantCreate/Plant2")
		plant_be_shovel_look.be_shovel_kill()
		_cance_shovel_or_end()
		
func _create_new_plant(plant_type:Global.PlantType, plant_cell:PlantCell):
	# 创建植物
	var new_plant :PlantBase= Global.PlantTypeSceneMap.get(plant_type).instantiate()
	
	plant_cell.add_child(new_plant)
	curr_plants.append(new_plant)
	new_plant.plant_free_signal.connect(_one_plant_free)
	new_plant.plant_free_signal.connect(plant_cell.one_plant_free)
	
	new_plant.global_position = plant_cell.plant_position.global_position
	
	plant_cell.is_plant = true
	plant_cell.plant = new_plant
	
	var plant_start_effect_scene = PlantStartEffectScene.instantiate()
	new_plant.add_child(plant_start_effect_scene)

func _one_plant_free(plant:PlantBase):
	curr_plants.erase(plant)
	

# 鼠标进入cell
func _on_cell_mouse_enter(plant_cell:PlantCell):
	
	if new_plant_static and not plant_cell.is_plant and not plant_cell.is_tombstone:
		
		new_plant_static_in_cell = true
		
		if main_game.mode_column:
			# 当前cell的列
			var curr_col = plant_cell.row_col.y
			#对每一行cell变量，获取当前列的所有cell
			for i in len(plant_cells_array):
				var plant_cell_row_col:PlantCell = plant_cells_array[i][curr_col]
				var new_node = new_plant_static_shadow_colum[i]
				## 如果当前cell已有植物
				if plant_cell_row_col.is_plant:
					continue
				new_node.global_position = plant_cell_row_col.plant_position.global_position
				new_node.modulate.a = 0.5
				
			
		else:
			new_plant_static_shadow.global_position = plant_cell.plant_position.global_position
			new_plant_static_shadow.modulate.a = 0.5

	
	# 如果手拿铲子
	if is_shovel and plant_cell.plant:
		plant_be_shovel_look = plant_cell.plant
		plant_be_shovel_look.be_shovel_look()

# 鼠标移出cell
func _on_cell_mouse_exit(plant_cell:PlantCell):
	if new_plant_static:
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

# 右键点击
func _input(event):
	if event is InputEventMouseButton:
		if new_plant_static:
			#右键点击
			if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				SoundManager.play_sfx("Card/Back")
				_cancel_plant_or_end()

			#左键点击空白
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not new_plant_static_in_cell:
				SoundManager.play_sfx("Card/Back")
				_cancel_plant_or_end()
		
		if is_shovel:
			#右键点击
			if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				SoundManager.play_sfx("Card/Back")
				if plant_be_shovel_look:
					plant_be_shovel_look.be_shovel_look_end()
					plant_be_shovel_look = null
				_cance_shovel_or_end()
			
			#左键点击空白
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not plant_be_shovel_look:
				SoundManager.play_sfx("Card/Back")
				_cance_shovel_or_end()
		

# 取消种植或者种植完成后
func _cancel_plant_or_end():
	curr_card = null
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
	plant_cell.add_child(tombstone)
	tombstone.position = Vector2(39,48)
	
	# 创建墓碑相关参数变化
	plant_cell.is_tombstone = true
	is_tombstone[pos.x][pos.y] = true
	tombstone_num += 1


## 黑夜关卡生成墓碑（生成数量，生成的最大列数，从右向左）
func create_tombstone(new_num:int):
	## 最大数量： 最大可生成列数 * 行数
	## 生成随机位置
	var selected_positions :Array[Vector2i]= _reandom_tombstone_pos(new_num)
	for pos in selected_positions:
		_create_one_tombstone(plant_cells_array[pos.x][pos.y], pos)

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
