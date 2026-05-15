extends Node2D

@export var player_scale = 1.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SceneManager.player.setup_for_location({
		"state": "mini",
		"scale": player_scale
	})
	# Формируем сценарий диалога
	var intro_dialogue: Array = [
		{"name": "Протагонист", "text": "Где я? Кажется, это заброшенная комната..."},
		{"name": "Голос из радио", "text": "Внимание! Выхода нет. Ищите подсказки."},
		{"name": "Протагонист", "text": "Нужно осмотреться и найти ключ от двери."}
	]
	
	# Генерируем событие. Укажите точный путь к вашей сцене диалога
	EventBus.dialogue_started.emit("res://scenes/ui/Dialogue.tscn", intro_dialogue)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
