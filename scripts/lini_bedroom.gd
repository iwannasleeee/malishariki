extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#pass
	#EventBus.location_change_requested.emit()
	EventBus.scene_became_visible.connect(_on_location_loaded)
	
	EventBus.add_quest.emit({
		"id": "pencils",
		"title": "Собери карандаши сын собаки",
		"description": "Собрано: 0/10",
		"completed": false
		})

func _on_location_loaded():
	print("test")
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
	
	EventBus.dialogue_started.emit("res://scenes/ui/dialogue/Dialogue.tscn",dialogue)
