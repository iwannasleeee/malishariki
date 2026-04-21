extends Node2D

@onready var canvas: TextureRect = $Canvas

# ==== Изображение ====
var image: Image
var texture: ImageTexture
var original_image: Image
var texture_dirty := false
# ==== Оптимизация ====
var upload_accum := 0.0
@export var upload_fps := 30.0

# ==== Рисование ====
var drawing := false
var last_pos: Vector2

# ==== Кисть ====
var brush_color: Color = Color.BLACK
@export var brush_size: int = 6
var brush_image: Image        # готовая кисть (маска * цвет, scaled)
var eraser_mask_image: Image  # маска формы ластика (белый круг)
var brush_masks: Dictionary = {}   # имя → Image оригинальная маска
var current_brush_name := ""

# Список кистей из папки brushes/
# Названия файлов без расширения — они же появятся на кнопках
const BRUSH_NAMES: Array[String] = ["BrushTexture", "BrushTexture", "BrushTexture", "BrushTexture"]

enum Tool { BRUSH, ERASER, TAPE }
var current_tool = Tool.BRUSH

# ==== Декоративный скотч ====
var tape_first_point := Vector2.ZERO
var tape_waiting_second_point := false

@export var tape_width: int = 280
@export var tape_repeat_px: float = 240.0
@export var tape_opacity: float = 1.0

var tape_texture_image: Image

var tape_viewport   : SubViewport
var tape_blend_rect : ColorRect
var tape_godot_tex  : ImageTexture   # tape_texture_image как Texture2D
var tape_canvas_snap: ImageTexture   # снимок canvas перед рендером

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

	var mask_tex = ImageTexture.create_from_image(original_image)
	_apply_mask_shader(mask_tex)

	canvas.texture = texture
	_load_brushes()
	_load_tape_texture()
	_setup_tape_gpu()          # ← добавь эту строку
	set_brush_size(brush_size)
	connect_ui()

func _process(delta):
	if texture_dirty:
		upload_accum += delta
		if upload_accum >= 1.0 / upload_fps:
			texture.update(image)
			texture_dirty = false
			upload_accum = 0.0

# =============== Обновление изображения ===================
# для оптимизации
func flush_texture():
	texture.update(image)
	texture_dirty = false
	upload_accum = 0.0
# ===================== Шейдеры =============================
func _apply_mask_shader(mask_tex: ImageTexture):
	var shader_code = """
shader_type canvas_item;
uniform sampler2D mask_texture : hint_default_white;

void fragment() {
	vec4 draw_color = texture(TEXTURE, UV);
	float mask_alpha = texture(mask_texture, UV).a;
	COLOR = vec4(draw_color.rgb, draw_color.a * mask_alpha);
}
"""
	var shader = Shader.new()
	shader.code = shader_code

	var mat = ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("mask_texture", mask_tex)

	canvas.material = mat

const TAPE_SHADER_CODE = """
shader_type canvas_item;

uniform sampler2D current_canvas : hint_default_transparent;
uniform sampler2D tape_tex       : hint_default_transparent;
uniform vec2  point_a;
uniform vec2  point_b;
uniform float half_width;
uniform float repeat_px;
uniform float tape_opacity;
uniform vec2  canvas_size;

vec4 blend_over(vec4 dst, vec4 src) {
	float a = src.a + dst.a * (1.0 - src.a);
	if (a <= 0.0) return vec4(0.0);
	return vec4(
		(src.rgb * src.a + dst.rgb * dst.a * (1.0 - src.a)) / a, a
	);
}

void fragment() {
	vec4 base = texture(current_canvas, UV);
	vec4 result = base;

	vec2  d    = point_b - point_a;
	float len  = length(d);

	if (len >= 1.0) {
		vec2  px    = UV * canvas_size;
		vec2  dir   = d / len;
		vec2  norm  = vec2(-dir.y, dir.x);
		vec2  rel   = px - point_a;
		float along = dot(rel, dir);
		float cross_d = dot(rel, norm);

		if (along >= 0.0 && along <= len && abs(cross_d) <= half_width) {
			float fade = clamp(half_width - abs(cross_d), 0.0, 1.0);
			float u    = mod(along, repeat_px) / repeat_px;
			float v    = (cross_d + half_width) / (half_width * 2.0);

			vec4 tape = texture(tape_tex, vec2(u, v));
			tape.a   *= fade * tape_opacity;
			result    = blend_over(base, tape);
		}
	}

	COLOR = result;
}
"""
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
# ==================== Загрузка скотча ======================
func _load_tape_texture():
	var path = "res://Assets/ui/paint/bigbabytape.png"
	if ResourceLoader.exists(path):
		var tex = load(path) as Texture2D
		if tex:
			tape_texture_image = tex.get_image()
			tape_texture_image.convert(Image.FORMAT_RGBA8)
			tape_godot_tex = ImageTexture.create_from_image(tape_texture_image)
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
func _bake_eraser_mask():
	var size := brush_size * 2 + 1
	eraser_mask_image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	eraser_mask_image.fill(Color(0, 0, 0, 0))

	var r := float(brush_size)
	var r2 := r * r

	for y in range(size):
		for x in range(size):
			var dx := float(x) - r
			var dy := float(y) - r
			if dx * dx + dy * dy <= r2:
				eraser_mask_image.set_pixel(x, y, Color(1, 1, 1, 1))

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
	_bake_eraser_mask()

func select_color(color: Color):
	current_tool = Tool.BRUSH
	brush_color = color
	_bake_brush_image()

# ===================== Ластик ==============================
func select_eraser():
	current_tool = Tool.ERASER
# ===================== Скотч ===============================
func select_tape():
	current_tool = Tool.TAPE
	tape_waiting_second_point = false

func draw_tape_segment(a: Vector2, b: Vector2) -> void:
	if tape_godot_tex == null:
		return
	if (b - a).length() < 1.0:
		return

	# Снимок текущего холста — передаём в шейдер как фон
	tape_canvas_snap = ImageTexture.create_from_image(image)

	var mat := tape_blend_rect.material as ShaderMaterial
	mat.set_shader_parameter("current_canvas", tape_canvas_snap)
	mat.set_shader_parameter("tape_tex",       tape_godot_tex)
	mat.set_shader_parameter("point_a",        a)
	mat.set_shader_parameter("point_b",        b)
	mat.set_shader_parameter("half_width",     float(tape_width) * 0.5)
	mat.set_shader_parameter("repeat_px",      tape_repeat_px)
	mat.set_shader_parameter("tape_opacity",   tape_opacity)
	mat.set_shader_parameter("canvas_size",
		Vector2(image.get_width(), image.get_height()))

	# Запускаем один рендер-кадр
	tape_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	await RenderingServer.frame_post_draw

	# Забираем результат обратно в image
	image = tape_viewport.get_texture().get_image()
	image.convert(Image.FORMAT_RGBA8)
	texture_dirty = true

func alpha_over(dst: Color, src: Color) -> Color:
	var out_a = src.a + dst.a * (1.0 - src.a)
	if out_a <= 0.0:
		return Color(0, 0, 0, 0)

	return Color(
		(src.r * src.a + dst.r * dst.a * (1.0 - src.a)) / out_a,
		(src.g * src.a + dst.g * dst.a * (1.0 - src.a)) / out_a,
		(src.b * src.a + dst.b * dst.a * (1.0 - src.a)) / out_a,
		out_a
	)
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
	$UI/Tape.pressed.connect(select_tape)
	$UI/Undo.pressed.connect(undo)
	$UI/Redo.pressed.connect(redo)
	for child in $UI.get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_STOP
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

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var p = get_image_pos(canvas.get_local_mouse_position())

			if current_tool == Tool.TAPE:
				if not tape_waiting_second_point:
					tape_first_point = p
					tape_waiting_second_point = true
				else:
					save_state()
					draw_tape_segment(tape_first_point, p)
					texture_dirty = true
					tape_waiting_second_point = false
				return

			drawing = true
			save_state()
			last_pos = p

		elif event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			flush_texture() #Обновление последнего кадра
			drawing = false

	elif event is InputEventMouseMotion and drawing:
		if current_tool == Tool.BRUSH or current_tool == Tool.ERASER:
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

func draw_eraser_stamp(pos: Vector2):
	if eraser_mask_image == null:
		return

	var size := brush_size * 2 + 1
	var x0 := int(pos.x) - brush_size
	var y0 := int(pos.y) - brush_size

	var src_x := maxi(x0, 0)
	var src_y := maxi(y0, 0)
	var src_w := mini(x0 + size, image.get_width()) - src_x
	var src_h := mini(y0 + size, image.get_height()) - src_y

	if src_w <= 0 or src_h <= 0:
		return

	var src_rect := Rect2i(src_x, src_y, src_w, src_h)
	var dst := Vector2i(src_x, src_y)

	var mask_x := src_x - x0
	var mask_y := src_y - y0

	var src_crop := original_image.get_region(src_rect)
	var mask_crop := eraser_mask_image.get_region(Rect2i(mask_x, mask_y, src_w, src_h))

	image.blit_rect_mask(src_crop, mask_crop, Rect2i(0, 0, src_w, src_h), dst)

func draw_brush(pos: Vector2):
	var x0 = int(pos.x) - brush_size
	var y0 = int(pos.y) - brush_size

	if current_tool == Tool.BRUSH:
		if brush_image == null:
			return
		var brush_rect = Rect2i(0, 0, brush_image.get_width(), brush_image.get_height())
		image.blend_rect(brush_image, brush_rect, Vector2i(x0, y0))

	#else:  # ERASER
		#var img_w = image.get_width()
		#var img_h = image.get_height()
		#var size = brush_size * 2 + 1
#
		## Обрезаем до границ изображения
		#var rx = clampi(x0, 0, img_w)
		#var ry = clampi(y0, 0, img_h)
		#var rw = mini(x0 + size, img_w) - rx
		#var rh = mini(y0 + size, img_h) - ry
#
		#if rw > 0 and rh > 0:
			#
			#image.blit_rect(original_image, Rect2i(rx, ry, rw, rh), Vector2i(rx, ry))

	else:  # ERASER
		draw_eraser_stamp(pos)
# ======================== СКОТЧ ============================
func _setup_tape_gpu():
	tape_viewport = SubViewport.new()
	tape_viewport.size = Vector2i(image.get_width(), image.get_height())
	tape_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	tape_viewport.transparent_bg = true
	add_child(tape_viewport)

	tape_blend_rect = ColorRect.new()
	tape_blend_rect.size = Vector2(image.get_width(), image.get_height())

	var shader = Shader.new()
	shader.code = TAPE_SHADER_CODE
	var mat = ShaderMaterial.new()
	mat.shader = shader
	tape_blend_rect.material = mat
	tape_viewport.add_child(tape_blend_rect)

	tape_canvas_snap = ImageTexture.new()
	
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
