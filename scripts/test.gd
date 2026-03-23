extends Node2D

@onready var canvas: TextureRect = $Canvas

# ==== Drawing ====
var image: Image
var texture: ImageTexture
var original_image: Image

var drawing := false
var last_pos: Vector2

# ==== Brush ====
var brush_color: Color = Color.BLACK
@export var brush_size: int = 6
var brush_image: Image
var brush_radius_sq: int

enum Tool { BRUSH, ERASER }
var current_tool = Tool.BRUSH

# ==== Undo / Redo ====
var undo_stack: Array[Image] = []
var redo_stack: Array[Image] = []
const MAX_HISTORY := 20

func _ready():
	# Берём текстуру, которую ты задал в Inspector
	var tex: Texture2D = canvas.texture

	# ВАЖНО: превращаем её в Image
	image = tex.get_image()
	original_image = image.duplicate()  # <-- важно
	# Создаём НОВУЮ texture (иначе update() не будет работать корректно)
	texture = ImageTexture.create_from_image(image)
	canvas.texture = texture

	set_brush_size(brush_size)

	connect_ui()

# ================= UI =================

func connect_ui():
	$UI/RedPencil.pressed.connect(func(): select_color(Color("#d92721")))
	$UI/OrangePencil.pressed.connect(func(): select_color(Color("#f78839")))
	$UI/YellowPencil.pressed.connect(func(): select_color(Color("#ffed63")))
	$UI/GreenPencil.pressed.connect(func(): select_color(Color("#44c753")))
	$UI/BluePencil.pressed.connect(func(): select_color(Color("#4287f5")))
	$UI/BrownPencil.pressed.connect(func(): select_color(Color("#80431b")))
	$UI/BlackPencil.pressed.connect(func(): select_color(Color.BLACK))  # или Color("#000000")
	$UI/PinkPencil.pressed.connect(func(): select_color(Color("#ee75e2")))

	$UI/Eraser.pressed.connect(select_eraser)
	$UI/Undo.pressed.connect(undo)
	$UI/Redo.pressed.connect(redo)

func select_color(color: Color):
	current_tool = Tool.BRUSH
	brush_color = color

func set_brush_size(size):
	brush_size = size
	brush_radius_sq = size * size
	
func generate_brush():
	brush_image = Image.create(brush_size*2, brush_size*2, false, Image.FORMAT_RGBA8)
	brush_image.fill(Color(0,0,0,0))

	for x in range(brush_size*2):
		for y in range(brush_size*2):
			var dx = x - brush_size
			var dy = y - brush_size

			if dx*dx + dy*dy <= brush_radius_sq:
				brush_image.set_pixel(x, y, Color.WHITE)
				
func select_eraser():
	current_tool = Tool.ERASER

# ================= Input =================

func get_image_pos(mouse_pos: Vector2) -> Vector2:
	var img_size = Vector2(image.get_size())
	var scale = img_size / canvas.size
	return mouse_pos * scale

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			drawing = event.pressed

			if drawing:
				save_state()  # сохраняем ДО начала рисования

			last_pos = get_image_pos(canvas.get_local_mouse_position())

	elif event is InputEventMouseMotion and drawing:
		var current_pos = get_image_pos(canvas.get_local_mouse_position())

		if not Rect2(Vector2.ZERO, image.get_size()).has_point(current_pos):
			return

		draw_line_on_image(last_pos, current_pos)
		last_pos = current_pos

# ================= Drawing =================

func draw_line_on_image(from: Vector2, to: Vector2):
	var distance = from.distance_to(to)
	var steps = int(distance)

	for i in range(steps):
		var t = float(i) / distance
		var pos = from.lerp(to, t)
		draw_brush(pos)

	draw_brush(to)

	texture.update(image)

func draw_brush(pos: Vector2):
	var x0 = int(pos.x)
	var y0 = int(pos.y)

	var color = brush_color
	var use_eraser = current_tool == Tool.ERASER

	for x in range(-brush_size, brush_size):
		for y in range(-brush_size, brush_size):
			var p = Vector2(x0 + x, y0 + y)

			if p.x < 0 or p.y < 0 or p.x >= image.get_width() or p.y >= image.get_height():
				continue

			if Vector2(x, y).length() <= brush_size:
				#image.set_pixelv(p, color)
				var base_color = image.get_pixelv(p)
				# рисуем только если пиксель не прозрачный
				if base_color.a > 0.1:
					if use_eraser:
						var original_color = original_image.get_pixelv(p)
						image.set_pixelv(p, original_color)
					else:
						image.set_pixelv(p, brush_color)

# ================= Undo / Redo =================

func save_state():
	var copy = image.duplicate()
	undo_stack.append(copy)

	if undo_stack.size() > MAX_HISTORY:
		undo_stack.pop_front()

	redo_stack.clear()

func undo():
	if undo_stack.is_empty():
		return

	redo_stack.append(image.duplicate())

	image = undo_stack.pop_back()
	texture.update(image)

func redo():
	if redo_stack.is_empty():
		return

	undo_stack.append(image.duplicate())

	image = redo_stack.pop_back()
	texture.update(image)
