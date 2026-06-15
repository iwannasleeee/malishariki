extends Node2D

signal trail_completed

@onready var dotted_line: Line2D = $DottedLine

# Радиус попадания в следующую точку
var checkpoint_radius := 60.0
# Максимальное расстояние от линии, после которого сброс
var max_deviation := 80.0

var next_checkpoint := 0
var checkpoints: Array[Vector2] = []
var is_active := true  # false после успеха

func _ready():
	for point in dotted_line.points:
		checkpoints.append(dotted_line.to_global(point))

func _process(_delta):
	if not is_active or checkpoints.is_empty():
		return

	var mouse_pos = get_global_mouse_position()

	# Проверяем попадание в следующую точку
	if mouse_pos.distance_to(checkpoints[next_checkpoint]) < checkpoint_radius:
		next_checkpoint += 1
		if next_checkpoint >= checkpoints.size():
			is_active = false
			trail_completed.emit()
			return

	# Сброс: если курсор слишком далеко от ближайшей пройденной/текущей точки
	if next_checkpoint > 0:
		var nearest_dist := _distance_to_line_segment(mouse_pos)
		if nearest_dist > max_deviation:
			_reset()

func _reset():
	next_checkpoint = 0
	dotted_line.default_color = Color(1, 1, 1, 0.7)  # возвращаем исходный цвет

func _distance_to_line_segment(mouse_pos: Vector2) -> float:
	var min_dist := INF
	for i in range(checkpoints.size() - 1):
		var d: float = _point_to_segment_dist(mouse_pos, checkpoints[i], checkpoints[i + 1])
		if d < min_dist:
			min_dist = d
	return min_dist

func _point_to_segment_dist(p: Vector2, a: Vector2, b: Vector2) -> float:
	var ab := b - a
	var ap := p - a
	var t: float = clamp(ap.dot(ab) / ab.dot(ab), 0.0, 1.0)
	return p.distance_to(a + ab * t)
