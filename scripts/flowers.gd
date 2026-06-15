extends InteractableObject
class_name Flowers


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func interact(player: Node):
	EventBus.minigame_started.emit("res://scenes/minigames/Krapiva/krapiva.tscn")
	#UIManager.show_minigame("res://scenes/minigames/Krapiva/krapiva.tscn")


func _on_clicked(obj: InteractableObject) -> void:
	pass # Replace with function body.
