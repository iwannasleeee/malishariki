extends Node2D

@export var player_scale = 1.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SceneManager.player.setup_for_location({
		"state": "mini",
		"scale": player_scale
	})
	# Формируем сценарий диалога
	var dialogue = [
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
	EventBus.dialogue_started.emit("res://scenes/ui/dialogue/Dialogue.tscn", dialogue)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
