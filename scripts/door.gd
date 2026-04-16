extends InteractableObject

@export_file("*.tscn") var target_scene: String
@export var spawn_point_name: String = "spawn"
func interact(player: Node) -> void:
	print("door: ", spawn_point_name)
	SceneManager.change_scene(target_scene, spawn_point_name)
