extends CanvasLayer
class_name StoreManager
## 商店场景不是新场景，而是创建新的商店场景节点覆盖原始场景

@onready var crazy_dave: CrazyDave = $CrazyDave
@export var all_goods :Array[Goods]
@onready var canvas_layer_confirm_goods: ConfirmGoods = $CanvasLayerConfirmGoods
@onready var coin_bank: CoinBank = $CoinBank

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.coin_value_label = coin_bank
	for goods in all_goods:
		goods.look_goods_signal.connect(crazy_dave.external_trigger_dialog)
		goods.look_end_goods_signal.connect(crazy_dave.external_trigger_dialog_end)
		## 确认购买页面
		goods.signal_pressed_this_goods.connect(canvas_layer_confirm_goods.appear_canvas_layer.bind(goods))
	

## 离开商店
func _on_store_main_menu_button_pressed() -> void:
	Global.exit_store()
