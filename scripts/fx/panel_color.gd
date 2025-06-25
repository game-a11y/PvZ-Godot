extends Panel
class_name Panel_color

var tween:Tween


func appear_once(duration: float = 0.3):
	tween = create_tween()  # 创建 Tween 实例
	
	visible = true
	#var light_color = Color(2, 2, 2, modulate.a)  # 会触发 set_hit_color -> _update_modulate
	var ori_color = modulate

	tween.tween_property(self, "modulate", ori_color + Color(0,0,0,0.3), duration * 0.5)
	tween.tween_property(self, "modulate", ori_color, duration * 0.5)
	
	await tween.finished
	visible = false
