extends Node2D
class_name Sun

@export var sun_value := 25
@export var card_manager: CardManager
## 阳光存在时间
@export var exist_time:float = 10.0
var collected := false  # 是否已被点击收集

func _ready() -> void:
	card_manager = get_tree().current_scene.get_node("Camera2D/CardManager")
	# 启动一个10秒定时器
	await get_tree().create_timer(exist_time).timeout
	
	# 如果还没被点击收集，自动销毁
	if not collected and is_instance_valid(self):
		_start_fade_out()
	
func _sun_scale(new_sun_value:int):
	var new_scale = new_sun_value/25.0
	scale = Vector2(new_scale,new_scale)


func _on_button_pressed() -> void:
	if collected:
		return  # 防止重复点击
	
	collected = true  # 设置已被收集
	
	SoundManager.play_sfx("Points")
	var parent_position = get_parent().global_position
	var tween = get_tree().create_tween()
	# 将节点从当前位置移动到(100, 200)，耗时1秒
	tween.tween_property(self, "position", parent_position, 0.5)
	$Button.queue_free()
	
	tween.finished.connect(func(): _sun_tween_end())

func _sun_tween_end():
	card_manager.sun += sun_value
	self.queue_free()


func _start_fade_out() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0)  # 🌫️ 1秒淡出
	tween.finished.connect(func(): 
		if not collected and is_instance_valid(self):
			self.queue_free()
	)

func on_sun_tween_finished():
	if Global.auto_collect_sun:
		_on_button_pressed()
