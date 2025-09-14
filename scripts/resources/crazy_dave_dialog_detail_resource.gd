extends Resource
class_name CrazyDaveDialogDetailResource
## 与戴夫的交流细节资源文件，每一句话

## 当前语句的文本内容
@export_multiline var text:String
## 戴夫当前语句是否为发疯动画
@export var is_crazy:bool = false
## 戴夫当前语句是否展示手上物品
@export var is_hand:bool = false
## TODO:戴夫当前语句是否为选择
@export var is_choosed:bool = false
