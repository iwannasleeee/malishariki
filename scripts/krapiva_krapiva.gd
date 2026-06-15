extends Area2D

signal nettle_toched()

@export var rotation_amplitude = PI/2
@export var rotation_speed = 1.5

@export var min_wind_speed = -6
@export var max_wind_speed = 7

@export var min_angle = -PI/2
@export var max_angle = PI/4

var rotation_time = 0
var rotation_d = 0

var wind_speed = 0
var cur_wind_speed = 0
var r = 0

func _ready() -> void:
	input_event.connect(_on_input_event)
	var r = randf_range(0.0, 1.0)
	
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_on_object_clicked()

func _on_object_clicked() -> void:
	nettle_toched.emit()
	
func _process(delta: float) -> void:
	rotation_time += rotation_speed * delta
	rotation_d = sin(rotation_time) * rotation_amplitude
	
	cur_wind_speed = wind_speed * abs(cos(rotation_time*3))
	
	var new_rotation = rotation_d + cur_wind_speed
	rotation = clamp(new_rotation,min_angle,max_angle)
	#print(rotation)
