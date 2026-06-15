extends InteractableObject
class_name FlowerBase
@export var flower_name: String = "white"
var is_taken = false

func interact(player: Node) -> void:
	#if !GameManager.collected_flowers.has(flower_name):
		#is_taken = true
		#GameManager.collected_flowers.append(flower_name)
		#print(GameManager.collected_flowers)
		#$"."._on_mouse_exit()
		#$".".queue_free()
	EventBus.minigame_started.emit("res://scenes/minigames/Krapiva/krapiva.tscn")
