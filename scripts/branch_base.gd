extends Control

@export var speed: float = 150.0

var hit_offset: Vector2
var hit_size: Vector2

@onready var hitbox: ColorRect = $Hitbox

func _ready() -> void:
	hit_offset = hitbox.position
	hit_size = hitbox.size * hitbox.scale
	hitbox.visible = false

func _process(delta: float) -> void:
	position.y += speed * delta
	if position.y > 820:
		queue_free()
		
#func _draw() -> void:
	#draw_rect(Rect2(hit_offset, hit_size), Color(1, 0, 0, 0.4))
