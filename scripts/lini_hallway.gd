extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
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
	await EventBus.dialogue_finished
	EventBus.comic_cutscene_started.emit("res://scenes/ComicCutscenes/cutscenes/comic_cutscene_TEST.tscn")

	
func _on_interact():
	EventBus.minigame_started.emit("res://scenes/minigames/YourMinigame.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
