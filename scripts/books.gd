extends Control

@onready var rows      : Array[Control] = [$Row1, $Row2, $Row3]
@onready var box_node  : Control        = $Box
@onready var fin_timer : Timer          = $CompletionTimer

# row_books[r] — книги ряда r, отсортированные по X слева направо
var row_books : Array = [[], [], []]

var dragging           : TextureRect = null
var drag_row_idx       : int         = -1
var drag_start_mouse_x : float       = 0.0
var drag_start_book_x  : float       = 0.0

# ── Инициализация ─────────────────────────────────────────────────────────────

func _ready() -> void:
	await get_tree().process_frame   # ждём финальный размер Control

	for r in 3:
		for child in rows[r].get_children():
			if child is TextureRect:
				child.mouse_filter = Control.MOUSE_FILTER_PASS
				row_books[r].append(child)
		_sort_row(r)

	box_node.mouse_filter = Control.MOUSE_FILTER_STOP
	box_node.gui_input.connect(_on_box_input)

	fin_timer.one_shot  = true
	fin_timer.wait_time = 1.0
	fin_timer.timeout.connect(_on_complete)

func _sort_row(r: int) -> void:
	row_books[r].sort_custom(func(a: TextureRect, b: TextureRect) -> bool:
		return a.position.x < b.position.x
	)

# ── Ввод ──────────────────────────────────────────────────────────────────────

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index != MOUSE_BUTTON_LEFT:
			return
		if mb.pressed:
			_try_start_drag(mb.global_position)
		else:
			dragging     = null
			drag_row_idx = -1

	elif event is InputEventMouseMotion and dragging != null:
		_do_drag(event.global_position.x)

func _try_start_drag(gpos: Vector2) -> void:
	for r in 3:
		for book : TextureRect in row_books[r]:
			if book.get_global_rect().has_point(gpos):
				dragging           = book
				drag_row_idx       = r
				drag_start_mouse_x = gpos.x
				drag_start_book_x  = book.position.x
				return

# ── Перетаскивание ────────────────────────────────────────────────────────────

func _do_drag(mouse_x: float) -> void:
	var new_x := drag_start_book_x + (mouse_x - drag_start_mouse_x)

	var r     := drag_row_idx
	var books : Array  = row_books[r]
	var idx   : int    = books.find(dragging)
	var bw    : float  = dragging.size.x

	# Левая граница: правый край левого соседа, или 0
	var left_bound : float
	if idx == 0:
		left_bound = 0.0
	else:
		var ln := books[idx - 1] as TextureRect
		left_bound = ln.position.x + ln.size.x

	# Правая граница: левый край правого соседа минус ширина книги, или край сцены
	var right_bound : float
	if idx == books.size() - 1:
		right_bound = size.x - bw
	else:
		var rn := books[idx + 1] as TextureRect
		right_bound = rn.position.x - bw

	dragging.position.x = clampf(new_x, left_bound, right_bound)

# ── Проверка туннеля ──────────────────────────────────────────────────────────
# Туннель открыт, если ни одна книга во всех 3 рядах не перекрывает центр коробки по X

func _is_tunnel_open() -> bool:
	var tunnel_x : float = box_node.position.x + box_node.size.x * 0.5
	for r in 3:
		var row_ox : float = rows[r].position.x   # обычно 0
		for book : TextureRect in row_books[r]:
			var bx := row_ox + book.position.x
			if bx < tunnel_x and tunnel_x < bx + book.size.x:
				return false   # в этом ряду книга перекрывает туннель
	return true

# ── Коробка ───────────────────────────────────────────────────────────────────

func _on_box_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			if _is_tunnel_open():
				box_node.hide()
				fin_timer.start()

func _on_complete() -> void:
	EventBus.minigame_finished.emit({})
	UIManager.hide_minigame()
