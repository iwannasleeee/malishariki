extends InteractableObject

func interact(player: Node) -> void:
	EventBus.paint_started.emit("res://scenes/minigames/Paint.tscn")
