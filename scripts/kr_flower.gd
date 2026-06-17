extends Area2D

enum FLOWERS_NAME {ANEMONE, LUTIK, TULIP, VASILEK}
@export var flower_name: FLOWERS_NAME
var is_taken = false
signal pick_me(flower: FLOWERS_NAME)

func _ready() -> void:
	# Подключаем сигнал input_event к функции внутри этого же скрипта
	input_event.connect(_on_input_event)
	input_pickable = true
	# Подключаем сигналы
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	# Устанавливаем указатель-руку (системный курсор "pointer")
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited():
	# Возвращаем обычную стрелку
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# Проверяем, что событие — это нажатие кнопки мыши
	if event is InputEventMouseButton:
		# Проверяем, что нажата именно ЛЕВАЯ кнопка мыши и она НАЖАТА (а не отпущена)
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_on_object_clicked()

func _on_object_clicked() -> void:
	is_taken = true
	pick_me.emit(flower_name)
	visible = false
