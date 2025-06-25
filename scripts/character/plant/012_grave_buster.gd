extends PlantBase
class_name GraveBuster

@export var is_eat_grave := false


func start_eat_grave():
	is_eat_grave = true
	$Gravebusterchomp.play()



func _end_eat_grave():
	var plant_cell : PlantCell = get_parent()
	plant_cell.delete_tombstone()
	
	_plant_free()
