extends Node2D

@onready var canvas: TextureRect = $Canvas

# ==== Изображение ====
var image: Image
var texture: ImageTexture
var original_image: Image
var texture_dirty := false

# ==== Рисование ====
var drawing := false
var last_pos: Vector2

# ==== Кисть ====
var brush_color: Color = Color.BLACK
@export var brush_size: int = 6
var brush_image: Image        # готовая кисть (маска * цвет, scaled)
var brush_masks: Dictionary = {}   # имя → Image оригинальная маска
var current_brush_name := ""

# Список кистей из папки brushes/
# Названия файлов без расширения — они же появятся на кнопках
const BRUSH_NAMES: Array[String] = ["BrushTexture", "BrushTexture", "BrushTexture", "BrushTexture"]

enum Tool { BRUSH, ERASER }
var current_tool = Tool.BRUSH

# ==== Ластик ====
# Офсеты для ластика (пиксельный обход, нужно читать original_image)
var eraser_offsets: Array[Vector2i] = []

# ==== Undo / Redo ====
var undo_stack: Array[Image] = []
var redo_stack: Array[Image] = []
const MAX_HISTORY := 20

# ===========================================================
func _ready():
	var tex: Texture2D = canvas.texture
	image = tex.get_image()
	original_image = image.duplicate()
	texture = ImageTexture.create_from_image(image)
	canvas.texture = texture

	_load_brushes()
	set_brush_size(brush_size)
	connect_ui()

func _process(_delta):
	if texture_dirty:
		texture.update(image)
		texture_dirty = false

# ===================== Загрузка кистей =====================

func _load_brushes():
	for name in BRUSH_NAMES:
		var path = "res://Assets/ui/paint/brushes/%s.png" % name
		if ResourceLoader.exists(path):
			var tex = load(path) as Texture2D
			if tex:
				brush_masks[name] = tex.get_image()
				brush_masks[name].convert(Image.FORMAT_RGBA8)

	# Берём первую доступную кисть как дефолтную
	if brush_masks.size() > 0:
		set_brush(brush_masks.keys()[0])

# Пересчитывается только при смене кисти / размера / цвета
func _bake_brush_image():
	if current_brush_name == "" or not brush_masks.has(current_brush_name):
		return

	var mask: Image = brush_masks[current_brush_name].duplicate()
	var size = brush_size * 2 + 1
	mask.resize(size, size, Image.INTERPOLATE_LANCZOS)

	brush_image = Image.create(size, size, false, Image.FORMAT_RGBA8)

	for x in range(size):
		for y in range(size):
			var mp = mask.get_pixel(x, y)
			if mp.a > 0.01:
				var c = brush_color
				# r-канал маски — интенсивность (мягкие края у soft-кисти)
				c.a = mp.a * mp.r if mp.r > 0.01 else mp.a
				brush_image.set_pixel(x, y, c)
			else:
				brush_image.set_pixel(x, y, Color(0, 0, 0, 0))

# Пересчитываем офсеты ластика (круглая форма фиксированная)
func _bake_eraser_offsets():
	eraser_offsets.clear()
	var r2 = brush_size * brush_size
	for x in range(-brush_size, brush_size + 1):
		for y in range(-brush_size, brush_size + 1):
			if x * x + y * y <= r2:
				eraser_offsets.append(Vector2i(x, y))

# ===================== Управление кистью ===================

func set_brush(name: String):
	if not brush_masks.has(name):
		return
	current_tool = Tool.BRUSH
	current_brush_name = name
	_bake_brush_image()

func set_brush_size(size: int):
	brush_size = clampi(size, 1, 100)
	_bake_brush_image()
	_bake_eraser_offsets()

func select_color(color: Color):
	current_tool = Tool.BRUSH
	brush_color = color
	_bake_brush_image()

func select_eraser():
	current_tool = Tool.ERASER

# ===================== UI ==================================

func connect_ui():
	# Цвета
	$UI/RedPencil.pressed.connect(func(): select_color(Color("#d92721")))
	$UI/OrangePencil.pressed.connect(func(): select_color(Color("#f78839")))
	$UI/YellowPencil.pressed.connect(func(): select_color(Color("#ffed63")))
	$UI/GreenPencil.pressed.connect(func(): select_color(Color("#44c753")))
	$UI/BluePencil.pressed.connect(func(): select_color(Color("#4287f5")))
	$UI/BrownPencil.pressed.connect(func(): select_color(Color("#80431b")))
	$UI/BlackPencil.pressed.connect(func(): select_color(Color.BLACK))
	$UI/PinkPencil.pressed.connect(func(): select_color(Color("#ee75e2")))

	# Инструменты
	$UI/Eraser.pressed.connect(select_eraser)
	$UI/Undo.pressed.connect(undo)
	$UI/Redo.pressed.connect(redo)

	# Кисти — кнопки должны называться UI/Brush_round, UI/Brush_soft и т.д.
	for name in BRUSH_NAMES:
		var btn_path = "UI/Brush_%s" % name
		if has_node(btn_path):
			get_node(btn_path).pressed.connect(func(): set_brush(name))

	# Слайдер размера — нода UI/SizeSlider
	if has_node("UI/SizeSlider"):
		var slider = $UI/SizeSlider
		slider.min_value = 1
		slider.max_value = 100
		slider.value = brush_size
		slider.value_changed.connect(func(v): set_brush_size(int(v)))

# ===================== Input ===============================

func get_image_pos(mouse_pos: Vector2) -> Vector2:
	var scale = Vector2(image.get_size()) / canvas.size
	return mouse_pos * scale

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			drawing = event.pressed
			if drawing:
				save_state()
			last_pos = get_image_pos(canvas.get_local_mouse_position())

	elif event is InputEventMouseMotion and drawing:
		var current_pos = get_image_pos(canvas.get_local_mouse_position())
		if not Rect2(Vector2.ZERO, image.get_size()).has_point(current_pos):
			return
		draw_line_on_image(last_pos, current_pos)
		last_pos = current_pos

# ===================== Drawing =============================

func draw_line_on_image(from: Vector2, to: Vector2):
	var distance = from.distance_to(to)
	if distance < 0.5:
		draw_brush(to)
		texture_dirty = true
		return

	# Шаг пропорционален размеру кисти — меньше итераций при большой кисти
	var step_size = max(1.0, brush_size * 0.35)
	var steps = int(distance / step_size)

	for i in range(steps + 1):
		var t = float(i) / float(steps) if steps > 0 else 1.0
		draw_brush(from.lerp(to, t))

	texture_dirty = true

func draw_brush(pos: Vector2):
	var x0 = int(pos.x) - brush_size
	var y0 = int(pos.y) - brush_size

	if current_tool == Tool.BRUSH:
		if brush_image == null:
			return
		var brush_rect = Rect2i(0, 0, brush_image.get_width(), brush_image.get_height())
		image.blend_rect(brush_image, brush_rect, Vector2i(x0, y0))

	else:  # ERASER
		var img_w = image.get_width()
		var img_h = image.get_height()
		for offset in eraser_offsets:
			var px = int(pos.x) + offset.x
			var py = int(pos.y) + offset.y
			if px < 0 or py < 0 or px >= img_w or py >= img_h:
				continue
			if image.get_pixel(px, py).a > 0.1:
				image.set_pixel(px, py, original_image.get_pixel(px, py))

# ===================== Undo / Redo =========================

func save_state():
	undo_stack.append(image.duplicate())
	if undo_stack.size() > MAX_HISTORY:
		undo_stack.pop_front()
	redo_stack.clear()

func undo():
	if undo_stack.is_empty(): return
	redo_stack.append(image.duplicate())
	image = undo_stack.pop_back()
	texture_dirty = true

func redo():
	if redo_stack.is_empty(): return
	undo_stack.append(image.duplicate())
	image = redo_stack.pop_back()
	texture_dirty = true
