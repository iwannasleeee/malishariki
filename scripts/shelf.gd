extends InteractableObject

func interact(player: Node) -> void:
	EventBus.minigame_started.emit("res://scenes/minigames/Tumba/tumba.tscn")
