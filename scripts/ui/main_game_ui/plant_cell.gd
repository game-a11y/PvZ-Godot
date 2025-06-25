extends Control
class_name PlantCell

signal click_cell
signal cell_mouse_enter
signal cell_mouse_exit

signal cell_delete_tombstone	## 删除墓碑信号

## 植物种植位置
@onready var plant_position: Control = $PlantPosition
## 当前格子植物
@export var plant:PlantBase
## 行和列
@export var row_col:Vector2i

## 是否有植物
@export var is_plant := false:
	get:
		return is_plant
	set(v):
		is_plant = v
		_judge_can_common_plant()
	
## 是否有墓碑
@export var is_tombstone := false:
	get:
		return is_tombstone
	set(v):
		is_tombstone = v
		_judge_can_common_plant()
	
## 是否有坑洞
@export var is_crater := false:
	get:
		return is_crater
	set(v):
		is_crater = v
		_judge_can_common_plant()

## 是否可以种植普通植物
@export var can_common_plant := true

## 当前cell的墓碑
var tombstone:TombStone
## 当前cell的坑洞
var crater:DoomShroomCrater

## 毁灭菇坑洞
const doom_shroom_scenes:PackedScene =  preload("res://scenes/fx/doom_shroom_crater.tscn")


func _ready() -> void:
	## 隐藏按钮样式
	var new_stylebox_normal = $Button.get_theme_stylebox("pressed").duplicate()
	$Button.add_theme_stylebox_override("normal", new_stylebox_normal)

func one_plant_free(plant:PlantBase):
	is_plant = false
	plant = null

func _judge_can_common_plant():
	if is_plant or is_tombstone or is_crater:
		can_common_plant = false
	else:
		can_common_plant = true


## 创建墓碑
func create_tombstone(tombstone:TombStone):
	self.tombstone = tombstone
	add_child(tombstone)
	tombstone.position = Vector2(39,48)
	is_tombstone = true
	
## 刪除墓碑，墓碑是墓碑吞噬者调用该函数
func delete_tombstone():
	tombstone.queue_free()
	is_tombstone = false
	## 像hand_manager发射信号
	cell_delete_tombstone.emit(self)


## 创建坑洞
func create_crater():
	self.crater = doom_shroom_scenes.instantiate()
	add_child(crater)
	crater.init_crater(1, self)
	is_crater = true

## 坑洞调用该函数，坑洞是自己消失后调用该函数
func delete_crater():
	crater.queue_free()
	is_crater = false


func _on_button_pressed() -> void:

	click_cell.emit(self)


func _on_button_mouse_entered() -> void:

	cell_mouse_enter.emit(self)


func _on_button_mouse_exited() -> void:

	cell_mouse_exit.emit(self)
