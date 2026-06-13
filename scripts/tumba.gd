extends Control

## ============================================================
## МИНИИГРА "РУКА В ЛАБИРИНТЕ"
## ------------------------------------------------------------
## Игрок зажимает и тащит спрайт "ладони". Спрайт "руки" (Line2D)
## тянется от фиксированной точки Anchor к ладони, огибая углы
## стен лабиринта (CollisionPolygon2D под нодой MazeWalls).
##
## При отпускании ЛКМ:
##  - след руки (Line2D) мгновенно очищается;
##  - ладонь анимированно возвращается в исходную позицию.
##
## Сбор предметов: если ладонь подходит к предмету ближе, чем
## collect_radius, и предмет ещё не собран — он считается собранным.
## ============================================================

## ----------------------- НАСТРОЙКИ -------------------------

## Радиус вокруг ладони, в котором клик мышью считается "захватом".
@export var grab_radius: float = 50.0

## Радиус, в котором ладонь "касается" предмета и забирает его.
@export var collect_radius: float = 45.0

## Время анимации возврата ладони на исходную позицию (сек).
@export var return_time: float = 0.35

## Толщина линии "руки".
@export var rope_width: float = 8.0

## Если рука огибает углы стен "не в ту сторону" — переключите этот флаг.
## Это зависит от порядка точек (winding) в ваших CollisionPolygon2D.
@export var flip_wrap_direction: bool = false

## Расстояние, через которое фиксируется новая точка следа.
@export var trail_step_distance: float = 30.0

## ----------------------- УЗЛЫ -------------------------------

@onready var palm: CharacterBody2D = $Palm
@onready var rope: Line2D = $Rope
@onready var anchor: Marker2D = $Anchor
@onready var maze_walls: Node = $MazeContainer/MazeWalls
@onready var items_container: Node2D = $ItemsContainer
@onready var status_label: Label = $UI/StatusLabel
@onready var win_label: Label = $UI/WinLabel

## ----------------------- СИГНАЛЫ -----------------------------

## Испускается при сборе каждого предмета.
signal item_collected(item_name: String, collected: int, total: int)

## Испускается, когда собраны все предметы.
signal maze_completed()

## ----------------------- ВНУТРЕННЕЕ СОСТОЯНИЕ -----------------

var palm_start_pos: Vector2
var dragging: bool = false

# Список точек "руки": [Anchor, ...точки изгибов..., Ладонь]
# Здесь храним всё, КРОМЕ последней точки (позиции ладони) —
# она добавляется динамически в _update_rope().
var rope_points: Array = []
var last_fixed_pos: Vector2

# Все рёбра стен лабиринта в глобальных координатах: [[A,B], [A,B], ...]
var wall_segments: Array = []

var collected_items: Dictionary = {}
var total_items: int = 0
var collected_count: int = 0

var return_tween: Tween


func _ready() -> void:
	rope.width = rope_width
	palm_start_pos = palm.position

	total_items = items_container.get_child_count()

	_build_wall_segments()

	rope.points = PackedVector2Array()
	win_label.visible = false
	_update_status_label()


## Собирает все рёбра всех CollisionPolygon2D, лежащих под MazeWalls,
## в глобальных координатах. Вызывайте _build_wall_segments() повторно,
## если геометрия стен меняется в runtime.
func _build_wall_segments() -> void:
	wall_segments.clear()
	for child in maze_walls.get_children():
		if child is CollisionPolygon2D:
			var poly: PackedVector2Array = child.polygon
			if poly.size() < 2:
				continue
			var gpoly: Array = []
			for p in poly:
				gpoly.append(child.global_transform * p)
			for i in range(gpoly.size()):
				var a: Vector2 = gpoly[i]
				var b: Vector2 = gpoly[(i + 1) % gpoly.size()]
				wall_segments.append([a, b])


## ----------------------- ВВОД ---------------------------------

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if not dragging and palm.global_position.distance_to(get_global_mouse_position()) <= grab_radius:
				_start_drag()
		else:
			if dragging:
				_end_drag()

	#elif event is InputEventMouseMotion and dragging:
		#var pos: Vector2 = get_global_mouse_position()
		## Не даём ладони выйти за пределы игрового поля
		#pos.x = clamp(pos.x, 0.0, size.x)
		#pos.y = clamp(pos.y, 0.0, size.y)
		#palm.global_position = pos


func _process(_delta: float) -> void:
	if dragging:
		var target: Vector2 = get_global_mouse_position()
		target.x = clamp(target.x, 0.0, size.x)
		target.y = clamp(target.y, 0.0, size.y)

		var motion: Vector2 = target - palm.global_position
		
		if motion.length() > 0.01:
			palm.rotation = motion.angle()+ PI/2
		
		# Двигаемся к курсору, скользя вдоль стен через физику
		var remaining := motion
		for i in range(4): # несколько итераций для скольжения по углам
			if remaining.length() < 0.01:
				break
			var collision: KinematicCollision2D = palm.move_and_collide(remaining)
			if collision == null:
				break
			remaining = remaining.slide(collision.get_normal())
			# обрезаем, чтобы не "проскальзывать" обратно к курсору сильнее, чем нужно
			if remaining.dot(motion) <= 0:
				break

		_update_rope(palm.global_position)
		_check_items()


## ----------------------- ЗАХВАТ / ОТПУСКАНИЕ --------------------

func _start_drag() -> void:
	dragging = true

	if return_tween and return_tween.is_running():
		return_tween.kill()

	rope_points = [anchor.global_position]
	last_fixed_pos = anchor.global_position
	_update_rope(palm.global_position)
	_check_items()


func _end_drag() -> void:
	dragging = false

	# След руки мгновенно исчезает
	rope_points.clear()
	rope.points = PackedVector2Array()
	last_fixed_pos = anchor.global_position
	
	# Ладонь анимированно возвращается на старт
	if return_tween and return_tween.is_running():
		return_tween.kill()

	return_tween = create_tween()
	return_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	return_tween.tween_property(palm, "position", palm_start_pos, return_time)


## ----------------------- АЛГОРИТМ "ОБВИВАНИЯ" СТЕН ---------------

## Пересчитывает точки изгиба "руки" так, чтобы линия Anchor -> ... -> target
## всегда была натянутой нитью, огибающей углы стен лабиринта.
## Обновляет след "руки": фиксирует новые точки через каждые
## trail_step_distance пикселей пути ладони и перерисовывает Line2D
## как прямую Anchor -> ...фикс.точки... -> target.
func _update_rope(target: Vector2) -> void:
	# Фиксируем новые точки, пока расстояние от последней зафиксированной
	# до текущей позиции ладони превышает шаг.
	while last_fixed_pos.distance_to(target) >= trail_step_distance:
		var dir: Vector2 = (target - last_fixed_pos).normalized()
		var new_point: Vector2 = last_fixed_pos + dir * trail_step_distance
		rope_points.append(new_point)
		last_fixed_pos = new_point

	var pts := PackedVector2Array()
	for p in rope_points:
		pts.append(rope.to_local(p))
	pts.append(rope.to_local(target))
	rope.points = pts

## Проверяет, пересекает ли отрезок a-b хотя бы одну стену
## (не считая пересечений почти точно в концах отрезка).
func _segment_blocked(a: Vector2, b: Vector2) -> bool:
	for edge in wall_segments:
		var ip = _segment_intersection(a, b, edge[0], edge[1])
		if ip != null and a.distance_to(ip) > 1.0 and b.distance_to(ip) > 1.0:
			return true
	return false


## Находит ближайшее к точке `a` пересечение отрезка a-b со стенами.
## Возвращает {"point": Vector2, "edge": [Vector2, Vector2]} или null.
func _find_closest_intersection(a: Vector2, b: Vector2):
	var best_dist := INF
	var best_point: Vector2 = Vector2.ZERO
	var best_edge = null

	for edge in wall_segments:
		var ip = _segment_intersection(a, b, edge[0], edge[1])
		if ip != null:
			var d: float = a.distance_to(ip)
			if d > 0.5 and d < best_dist:
				best_dist = d
				best_point = ip
				best_edge = edge

	if best_edge == null:
		return null
	return {"point": best_point, "edge": best_edge}


## Выбирает, какую из двух вершин ребра (v1, v2) использовать как
## новую точку изгиба, чтобы "рука" огибала угол стены в правильную сторону.
func _choose_pivot(a: Vector2, b: Vector2, v1: Vector2, v2: Vector2) -> Vector2:
	var cross: float = (v2.x - v1.x) * (a.y - v1.y) - (v2.y - v1.y) * (a.x - v1.x)
	var pick_v1: bool = cross > 0.0
	if flip_wrap_direction:
		pick_v1 = not pick_v1
	return v1 if pick_v1 else v2


## Классическое пересечение двух отрезков. Возвращает точку пересечения
## или null, если отрезки не пересекаются (с небольшим эпсилон-допуском).
func _segment_intersection(p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2):
	var d1: Vector2 = p2 - p1
	var d2: Vector2 = p4 - p3
	var denom: float = d1.x * d2.y - d1.y * d2.x

	if abs(denom) < 0.0001:
		return null

	var t: float = ((p3.x - p1.x) * d2.y - (p3.y - p1.y) * d2.x) / denom
	var u: float = ((p3.x - p1.x) * d1.y - (p3.y - p1.y) * d1.x) / denom

	if t > 0.0001 and t < 0.9999 and u > -0.0001 and u < 1.0001:
		return p1 + d1 * t

	return null


## ----------------------- СБОР ПРЕДМЕТОВ ---------------------------

func _check_items() -> void:
	for item in items_container.get_children():
		if collected_items.has(item.name):
			continue
		if palm.global_position.distance_to(item.global_position) <= collect_radius:
			_collect_item(item)


func _collect_item(item: Node2D) -> void:
	collected_items[item.name] = true
	collected_count += 1
	item.visible = false

	item_collected.emit(item.name, collected_count, total_items)
	_update_status_label()

	if collected_count >= total_items:
		maze_completed.emit()
		win_label.visible = true


func _update_status_label() -> void:
	status_label.text = "Собрано: %d / %d" % [collected_count, total_items]
