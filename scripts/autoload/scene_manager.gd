extends Node

var spawn_point_name: String = ""

func change_scene(scene_path: String, spawn_name: String = ""):
	spawn_point_name = spawn_name
	get_tree().change_scene_to_file(scene_path)
