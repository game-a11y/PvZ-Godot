extends Node2D
class_name Pool


@onready var pool_base: Sprite2D = $PoolBase
@onready var pool: Sprite2D = $Pool
## 泳池白天图片
const POOL_BASE = preload("res://assets/image/background/pool_base.jpg")
const POOL = preload("res://assets/image/background/pool.jpg")

## 泳池黑夜图片
const POOL_BASE_NIGHT = preload("res://assets/image/background/pool_base_night.jpg")
const POOL_NIGHT = preload("res://assets/image/background/pool_night.jpg")


func init_pool(game_bg:ResourceLevelData.GameBg):
	match game_bg:
		ResourceLevelData.GameBg.Pool:
			pool_base.texture = POOL_BASE
			pool.texture = POOL

		ResourceLevelData.GameBg.Fog:
			pool_base.texture = POOL_BASE_NIGHT
			pool.texture = POOL_NIGHT
