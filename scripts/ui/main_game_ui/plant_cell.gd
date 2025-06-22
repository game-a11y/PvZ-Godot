extends Control
class_name PlantCell

signal click_cell
signal cell_mouse_enter
signal cell_mouse_exit
## 植物种植位置
@onready var plant_position: Control = $PlantPosition
## 当前格子植物
@export var plant:PlantBase
## 行和列
@export var row_col:Vector2i

## 是否有植物
@export var is_plant := false
## 是否有墓碑
@export var is_tombstone := false


func _ready() -> void:
	## 隐藏按钮样式
	var new_stylebox_normal = $Button.get_theme_stylebox("pressed").duplicate()
	$Button.add_theme_stylebox_override("normal", new_stylebox_normal)

func one_plant_free(plant:PlantBase):
	is_plant = false
	plant = null



func _on_button_pressed() -> void:

	click_cell.emit(self)


func _on_button_mouse_entered() -> void:

	cell_mouse_enter.emit(self)


func _on_button_mouse_exited() -> void:

	cell_mouse_exit.emit(self)
