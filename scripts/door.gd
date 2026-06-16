extends InteractableObject

signal lini_wanna_go(obj: InteractableObject)
@export_file("*.tscn") var target_scene: String
@export var spawn_point_name: String = "spawn"
func interact(player: Node) -> void:
	lini_wanna_go.emit(self)
