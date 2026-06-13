extends Area2D

var speed: float = 150.0

func _process(delta: float) -> void:
	position.y += speed * delta

	# самоудаление, когда ветка ушла за нижний край
	if position.y > get_viewport_rect().size.y + 100:
		queue_free()
