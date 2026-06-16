extends InteractableObject
class_name Papa_Tigr

@onready var papa_tigr_sprite: Sprite2D = $PapaTigrSprite
var is_clicked = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	EventBus.scene_became_visible.connect(_on_location_load)
	
func _on_location_load():
	print("test1")
	papa_tigr_sprite.hide()
	print("test2")

func interact(player: Node):
	if is_clicked == true:
		return
	is_clicked = true
		# Формируем сценарий диалога
	var before_tigr_dialogue = [
		{
			"name": "Lini",
			"text": "Привет! Рада тебя видеть.",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
		{
			"name": "Lini",
			"text": "...",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # можно менять анимацию внутри диалога
		},
		{
			"name": "",                # строчка без портрета
			"text": "Где-то вдали залаяла собака.",
		},
	]
	var after_tigr_dialogue = [
		{
			"name": "Lini",
			"text": "Привет! Рада тебя видеть.",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
		{
			"name": "Lini",
			"text": "...",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # можно менять анимацию внутри диалога
		},
		{
			"name": "",                # строчка без портрета
			"text": "Где-то вдали залаяла собака.",
		},
	]
	# Генерируем событие. Укажите точный путь к вашей сцене диалога
	EventBus.dialogue_started.emit("res://scenes/ui/dialogue/Dialogue.tscn", before_tigr_dialogue)
	await EventBus.dialogue_finished
	
	await UIManager.fade_out()
	papa_tigr_sprite.show()
	await get_tree().create_timer(1.5).timeout
	await UIManager.fade_in()
	
	EventBus.dialogue_started.emit("res://scenes/ui/dialogue/Dialogue.tscn", after_tigr_dialogue)
	await EventBus.dialogue_finished
	
	EventBus.minigame_started.emit("res://scenes/minigames/TigerUp/tiger_up.tscn")
