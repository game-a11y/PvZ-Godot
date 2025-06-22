extends Camera2D
class_name MainGameCamera


# 返回 Tween 对象，供外部 await
func move_to(target_pos: Vector2, duration: float, other_node: Node = null) -> Signal:
	var tween = get_tree().create_tween()

	tween.tween_property(self, "global_position", target_pos, duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)

	
	return tween.finished
	
