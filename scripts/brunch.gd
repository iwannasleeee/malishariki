extends Area2D

var speed: float = 350.0

func _process(delta: float) -> void:
	position.y += speed * delta

	# самоудаление, когда ветка ушла за нижний край
	if position.y > get_viewport_rect().size.y + 1000:
		queue_free()
