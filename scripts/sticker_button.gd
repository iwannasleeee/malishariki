extends TextureButton

@export var sticker_index: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _has_point(point: Vector2) -> bool:
	if texture_normal == null:
		return false
	
	var img = texture_normal.get_image()
	if img == null:
		return false
	
	var scaled = point * Vector2(img.get_size()) / size
	var px = Vector2i(scaled)
	
	if px.x < 0 or px.y < 0 or px.x >= img.get_width() or px.y >= img.get_height():
		return false
	
	return img.get_pixelv(px).a > 0.1
