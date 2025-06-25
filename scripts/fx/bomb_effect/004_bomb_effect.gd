extends Node2D
class_name DoomBombEffect

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func activate_bomb_effect():
	visible = true
	animation_player.play("idle")
	await animation_player.animation_finished
	
	queue_free()
