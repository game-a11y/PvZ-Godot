extends BulletPea
class_name BulletFume


func _on_area_2d_area_entered(area: Area2D) -> void:

	var zombie :ZombieBase = area.get_parent()
	_attack_zombie(zombie)
