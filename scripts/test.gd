extends Node2D

@onready var canvas: TextureRect = $Canvas

# ==== Drawing ====
var image: Image
var texture: ImageTexture

var drawing := false
var last_pos: Vector2

var brush_color: Color = Color.BLACK
var brush_size: int = 6

enum Tool { BRUSH, ERASER }
var current_tool = Tool.BRUSH

# ==== Undo / Redo ====
var undo_stack: Array[Image] = []
var redo_stack: Array[Image] = []
const MAX_HISTORY := 20

func _ready():
	image = Image.create(800, 600, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)

	texture = ImageTexture.create_from_image(image)
	canvas.texture = texture

	connect_ui()

# ================= UI =================

func connect_ui():
	$UI/PencilRed.pressed.connect(func(): select_color(Color.RED))
	$UI/PencilBlue.pressed.connect(func(): select_color(Color.BLUE))
	$UI/PencilGreen.pressed.connect(func(): select_color(Color.GREEN))

	$UI/Eraser.pressed.connect(select_eraser)
	$UI/Undo.pressed.connect(undo)
	$UI/Redo.pressed.connect(redo)

func select_color(color: Color):
	current_tool = Tool.BRUSH
	brush_color = color

func select_eraser():
	current_tool = Tool.ERASER

# ================= Input =================

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			drawing = event.pressed

			if drawing:
				save_state()  # сохраняем ДО начала рисования

			last_pos = canvas.get_local_mouse_position()

	elif event is InputEventMouseMotion and drawing:
		var current_pos = canvas.get_local_mouse_position()

		if not Rect2(Vector2.ZERO, canvas.size).has_point(current_pos):
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
	if current_tool == Tool.ERASER:
		color = Color.WHITE

	for x in range(-brush_size, brush_size):
		for y in range(-brush_size, brush_size):
			var p = Vector2(x0 + x, y0 + y)

			if p.x < 0 or p.y < 0 or p.x >= image.get_width() or p.y >= image.get_height():
				continue

			if Vector2(x, y).length() <= brush_size:
				image.set_pixelv(p, color)

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
