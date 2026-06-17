extends TextureRect

var hovered := false
var _img: Image

func _ready() -> void:
	# Загружаем текстуру из ассетов
	texture = load("res://Assets/interactable/QuokkaHome/QuokkaHome_LIT.PNG")
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Кэшируем Image сразу — get_image() медленная
	if texture:
		_img = texture.get_image()
		# Конвертируем в RGBA8 если нужно
		if _img.get_format() != Image.FORMAT_RGBA8:
			_img.convert(Image.FORMAT_RGBA8)

func _process(_delta) -> void:
	var mp = get_local_mouse_position()
	var was_hovered = hovered
	hovered = _pixel_hit(mp)
	if hovered != was_hovered:
		queue_redraw()

func _pixel_hit(lp: Vector2) -> bool:
	if not _img:
		return false
	var uv  = lp / size
	var tsz = Vector2(_img.get_width(), _img.get_height())
	var px  = (uv * tsz).floor()
	if px.x < 0 or px.y < 0 or px.x >= tsz.x or px.y >= tsz.y:
		return false
	return _img.get_pixel(int(px.x), int(px.y)).a > 0.1

func _draw() -> void:
	if hovered:
		draw_rect(Rect2(Vector2.ZERO, size), Color(1, 1, 1, 0.18))
