extends InteractableObject
class_name Paint_Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()

func interact(player: Node) -> void:
	EventBus.paint_started.emit("res://scenes/minigames/Paint/Paint.tscn")
