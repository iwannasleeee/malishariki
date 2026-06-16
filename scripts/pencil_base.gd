extends InteractableObject
class_name PencilBase
@export var color_name: String = "white"
var is_taken = false

func interact(player: Node) -> void:
	EventBus.pencil_taken.emit(self)
	is_taken = true
	print(GameManager.collected_pencils)
	$"."._on_mouse_exit()
	$".".queue_free()
