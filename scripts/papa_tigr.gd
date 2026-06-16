extends InteractableObject
class_name Papa_Tigr

@onready var papa_tigr_sprite: Sprite2D = $PapaTigrSprite
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	papa_tigr_sprite.hide()
	
func interact(player: Node):
	
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
