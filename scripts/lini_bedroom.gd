extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#pass
	EventBus.location_change_requested.emit()
	EventBus.add_quest.emit({
		"id": "pencils",
		"title": "Собери карандаши сын собаки",
		"description": "Собрано: 0/10",
		"completed": true
		})
