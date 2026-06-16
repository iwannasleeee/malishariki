extends Node2D

@onready var pencils: Node2D = $Pencils
var total_pencils_count = 10
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	total_pencils_count = get_children().size()
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

func _pencil_taken_handler(obj: PencilBase):
	if !GameManager.collected_pencils.has(obj.color_name):
		GameManager.collected_pencils.append(obj.color_name)
	#var collected_pencils_count = collected_pencils.
	EventBus.update_quest.emit({
		"id":"pencils",
		"description": "Собрано карандашей: {к1}/{к2}"
		.format({
			"к1": GameManager.collected_pencils.size(),
			"к2": total_pencils_count
			})
		})
	if GameManager.collected_pencils.size() == 10:
		EventBus.update_quest.emit({
			"id":"pencils",
			"completed": true,
		})
