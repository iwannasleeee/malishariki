extends Node

var spawn_point_name: String = ""
var world: Node2D
var player: CharacterBody2D

func initialize(w: Node2D, p: CharacterBody2D) -> void:
	world = w
	player = p

func change_scene(scene_path: String, spawn_name: String = ""):
	spawn_point_name = spawn_name
	get_tree().change_scene_to_file(scene_path)
