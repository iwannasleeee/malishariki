extends Node2D

@onready var canvas: TextureRect = $Canvas
@onready var color_picker: ColorPickerButton = $ColorPicker

var image: Image
var texture: ImageTexture

var drawing := false
var last_pos: Vector2

var brush_color: Color = Color.BLACK
var brush_size: int = 6

func _ready():
	# Создаём холст
	image = Image.create(800, 600, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)

	texture = ImageTexture.create_from_image(image)
	canvas.texture = texture

	# Подключаем выбор цвета
	#color_picker.color_changed.connect(_on_color_changed)

func _on_color_changed(color: Color):
	brush_color = color

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			drawing = event.pressed
			last_pos = canvas.get_local_mouse_position()

	elif event is InputEventMouseMotion and drawing:
		var current_pos = canvas.get_local_mouse_position()
		draw_line_on_image(last_pos, current_pos)
		last_pos = current_pos

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

	for x in range(-brush_size, brush_size):
		for y in range(-brush_size, brush_size):
			var p = Vector2(x0 + x, y0 + y)

			if p.x < 0 or p.y < 0 or p.x >= image.get_width() or p.y >= image.get_height():
				continue

			if Vector2(x, y).length() <= brush_size:
				image.set_pixelv(p, brush_color)
