extends InteractableObject

func interact(player: Node) -> void:
	EventBus.minigame_started.emit("res://scenes/minigames/Books/books.tscn")
