extends Node2D

signal trail_completed

@onready var checkpoints_node: Node2D = $Checkpoints

var is_drawing := false
var next_checkpoint := 0
var checkpoint_radius := 30.0
var checkpoints: Array[Vector2] = []

func _ready():
	# Собираем позиции всех Marker2D из узла Checkpoints
	for child in checkpoints_node.get_children():
		checkpoints.append(child.global_position)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		is_drawing = event.pressed

func _process(_delta):
	if not is_drawing or next_checkpoint >= checkpoints.size():
		return
	var mouse_pos = get_global_mouse_position()
	if mouse_pos.distance_to(checkpoints[next_checkpoint]) < checkpoint_radius:
		next_checkpoint += 1
		if next_checkpoint >= checkpoints.size():
			trail_completed.emit()
