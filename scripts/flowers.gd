extends InteractableObject


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func interact(player: Node):
	EventBus.minigame_started.emit("res://scenes/minigames/Krapiva/krapiva.tscn")
	UIManager.show_minigame("res://scenes/minigames/Krapiva/krapiva.tscn")
