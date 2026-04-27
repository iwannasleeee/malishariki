extends InteractableObject
class_name PencilBase
@export var color_name: String = "white"
var is_taken = false

func interact(player: Node) -> void:
	if !GameManager.collected_pencils.has(color_name):
		is_taken = true
		GameManager.collected_pencils.append(color_name)
		print(GameManager.collected_pencils)
		$"."._on_mouse_exit()
		$".".queue_free()
