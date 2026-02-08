extends CharacterBody2D

@export var speed: float = 200.0
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

func _ready():
	# Эти колбэки нужны для синхронизации движения с физическим процессом
	navigation_agent.path_desired_distance = 2.0
	navigation_agent.target_desired_distance = 5.0

	# Ждем, пока не пройдет первый кадр, чтобы навигация точно была готова
	await get_tree().physics_frame
	# Устанавливаем начальную позицию агента на позицию персонажа
	navigation_agent.target_position = global_position

func _input(event):
	# По клику левой кнопкой мыши ставим новую цель
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Конвертируем позицию мыши (в экранных координатах) в глобальные координаты мира
		var target_position = get_global_mouse_position()
		# Командуем агенту вычислить путь к этой цели
		navigation_agent.target_position = target_position
		# Можно тут же запустить анимацию ходьбы

func _physics_process(delta):
	# Если путь к цели еще не построен или персонаж уже у цели - не двигаемся
	if navigation_agent.is_navigation_finished():
		# velocity = Vector2.ZERO # Останавливаем персонажа, если нужно
		# Можно запустить анимацию покоя
		return

	# Получаем следующую точку на пути от агента
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	# Вычисляем направление к этой точке
	var direction: Vector2 = global_position.direction_to(next_path_position)
	# Задаем скорость (velocity) персонажа
	var intended_velocity = direction * speed

	# Если включено избегание (Avoidance), используем эту функцию
	if navigation_agent.avoidance_enabled:
		# Агент сам скорректирует скорость, чтобы избежать столкновений с другими агентами
		navigation_agent.velocity = intended_velocity
		velocity = navigation_agent.get_velocity()
	else:
		# Иначе просто применяем вычисленную скорость
		velocity = intended_velocity

	# Двигаем персонажа с помощью стандартного метода move_and_slide()
	move_and_slide()

	## (Опционально) Поворачиваем спрайт в сторону движения
	#if velocity.length() > 0.1:
		#$Sprite2D.look_at(global_position + velocity)
