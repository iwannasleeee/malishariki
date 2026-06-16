extends Control

enum FLOWERS_NAME {ANEMONE, LUTIK, TULIP, VASILEK}
@onready var flowers = $Flowers
@onready var nettles = $Nettles

var win_condition: Dictionary = {
	FLOWERS_NAME.ANEMONE: 4,
	FLOWERS_NAME.LUTIK: 8,
	FLOWERS_NAME.TULIP: 5,
	FLOWERS_NAME.VASILEK: 6,
}

var collected_flowers : Dictionary = {
	FLOWERS_NAME.ANEMONE: 0,
	FLOWERS_NAME.LUTIK: 0,
	FLOWERS_NAME.TULIP: 0,
	FLOWERS_NAME.VASILEK: 0,
}

var nettle_count = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	flowers_connect()
	krapiva_connect()

func flowers_connect():
	print("yes")
	for child in flowers.get_children():
		if child.has_signal("pick_me"):
			child.pick_me.connect(_collect_flower)
func krapiva_connect():
	for child in nettles.get_children():
		if child.has_signal("nettle_toched"):
			child.nettle_toched.connect(_touch_nettle)

func _collect_flower(flower):
	if not collected_flowers.has(flower):
		collected_flowers[flower] = 1
	else:
		collected_flowers[flower] += 1
	
	if _is_win_condition():
		EventBus.minigame_finished.emit({
			"result":"done"
		})
		UIManager.hide_minigame()

func _is_win_condition():
	for flower in win_condition:
		if win_condition[flower] > collected_flowers[flower]:
			return false
	return true
func _touch_nettle():
	nettle_count += 1
	_show_ai()
	if nettle_count >= 4:
		EventBus.minigame_finished.emit({})
		UIManager.hide_minigame()
func _show_ai():
	print("АЙ!!!!!!")
	#Здесь добавить лейблы с количеством цветов и обжогов
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
