extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#pass
	EventBus.location_change_requested.emit()
