extends Node

var world: Node2D
var player: CharacterBody2D
var current_location: Node2D
var spawn_point_name: String

func initialize(w: Node2D, p: CharacterBody2D) -> void:
	world = w
	player = p

func change_scene(scene_path: String, spawn_name: String = "") -> void:
	# Удаляем старую локацию
	if current_location and is_instance_valid(current_location):
		current_location.queue_free()
		await current_location.tree_exited

	# Загружаем новую локацию в World
	var packed: PackedScene = load(scene_path)
	current_location = packed.instantiate()
	world.add_child(current_location)

	# Перемещаем игрока к точке спауна
	if spawn_name != "":
		var spawn := current_location.find_child(spawn_name, true, false) as Marker2D
		if spawn:
			player.global_position = spawn.global_position

	# Переключаем камеру
	_update_camera()

func _update_camera() -> void:
	var player_cam := player.get_node_or_null("Camera2D") as Camera2D

	# Ищем фиксированную камеру среди потомков текущей локации
	var fixed_cam: Camera2D = null
	for node in get_tree().get_nodes_in_group("fixed_camera"):
		if node is Camera2D and current_location.is_ancestor_of(node):
			fixed_cam = node
			break

	if fixed_cam:
		if player_cam:
			player_cam.enabled = false
		fixed_cam.enabled = true          # Godot 4: enabled = true делает камеру активной
	else:
		if player_cam:
			player_cam.enabled = true
		# Убеждаемся что никакая фиксированная камера не осталась включённой
		for node in get_tree().get_nodes_in_group("fixed_camera"):
			if node is Camera2D:
				node.enabled = false
