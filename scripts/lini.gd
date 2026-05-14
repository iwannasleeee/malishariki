extends CharacterBody2D
class_name Lini
enum State { NORMAL, MINI }

@export var current_state: State = State.NORMAL

@export var config_normal: PlayerStateConfig
@export var config_mini: PlayerStateConfig

var current_config: PlayerStateConfig

# Параметры для каждого состояния
@export var speed_normal: float = 200.0
@export var speed_mini: float = 150.0

@export var jump_height_mini: float = 24.0
@export var jump_duration_mini: float = 0.4

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D  # Предполагаем, что так называется нода
@onready var camera: Camera2D = $Camera2D

@export var camera_limits_left: float = 0
@export var camera_limits_top: float = 0
@export var camera_limits_right: float = 2000
@export var camera_limits_bottom: float = 1000
@export var use_camera_limits: bool = true


var jump_time: float = 0.0
var sprite_base_y: float

# Переменная для отслеживания состояния движения
var is_moving: bool = false
var current_interactable: InteractableObject = null

func apply_state(config: PlayerStateConfig):
	current_config = config
	
func _ready():
	await get_tree().process_frame
	
	apply_state(config_normal if current_state == State.NORMAL else config_mini)
	
	EventBus.interactable_interact.connect(_interactable_interact)
	
	var spawn_name = SceneManager.spawn_point_name
	if spawn_name != "":
		var spawn = find_spawn_point(spawn_name)
		if spawn:
			global_position = spawn.global_position
			
	sprite_base_y = animated_sprite.position.y
	camera.make_current()
	
	if use_camera_limits:
		setup_camera_limits()
		
	# Эти колбэки нужны для синхронизации движения с физическим процессом
	navigation_agent.path_desired_distance = 2.0
	navigation_agent.target_desired_distance = 5.0

	# Ждем, пока не пройдет первый кадр, чтобы навигация точно была готова
	await get_tree().physics_frame
	# Устанавливаем начальную позицию агента на позицию персонажа
	navigation_agent.target_position = global_position
	
	# Начинаем с анимации idle
	play_idle_animation()

func find_spawn_point(name: String) -> SpawnPoint:
	for node in get_tree().get_nodes_in_group("spawn_points"):
		if node is SpawnPoint and node.spawn_name == name:
			return node
	return null
	
func _unhandled_input(event: InputEvent) -> void:
	# По клику левой кнопкой мыши ставим новую цель
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Сбрасываем предыдущее намерение взаимодействия при любом новом клике
		current_interactable = null
		# Конвертируем позицию мыши (в экранных координатах) в глобальные координаты мира
		var target_position = get_global_mouse_position()
		# Командуем агенту вычислить путь к этой цели
		navigation_agent.target_position = target_position

func setup_camera_limits():
	camera.limit_left = camera_limits_left
	camera.limit_top = camera_limits_top
	camera.limit_right = camera_limits_right
	camera.limit_bottom = camera_limits_bottom
	camera.limit_smoothed = true

func setup_for_location(config: Dictionary):
	if config.has("state"):
		match config["state"]:
			"normal":
				current_state = State.NORMAL
			"mini":
				current_state = State.MINI
		play_idle_animation()
	if config.has("scale"):
		self.scale.x = config["scale"]
		self.scale.y = config["scale"]

func _physics_process(delta):
	# Если путь к цели еще не построен или персонаж уже у цели - не двигаемся
	if navigation_agent.is_navigation_finished():
		if current_interactable:
			current_interactable.interact(self)
			current_interactable = null
		if current_config and current_state == State.MINI:
			var jump_duration = current_config.jump_duration
			var jump_height = current_config.jump_height
			if jump_time < jump_duration && jump_time > 0.0:
				jump_time += delta
				if jump_time >= jump_duration:
					jump_time = 0.0
					animated_sprite.position.y = sprite_base_y

				var t = jump_time / jump_duration
				var height = 4.0 * jump_height * t * (1.0 - t)
				animated_sprite.position.y = sprite_base_y - height

		if is_moving:
			is_moving = false
			play_idle_animation()
			velocity = Vector2.ZERO
		return

	# Получаем следующую точку на пути от агента
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	# Вычисляем направление к этой точке
	var direction: Vector2 = global_position.direction_to(next_path_position)
	
	# Если мы не двигались, но теперь начали движение
	if not is_moving:
		is_moving = true
		play_walk_animation()
	
	# Определяем направление для анимации (опционально)
	update_sprite_direction(direction)
	
	# Задаем скорость (velocity) персонажа
	var intended_velocity = direction * speed_normal

	# Если включено избегание (Avoidance), используем эту функцию
	if navigation_agent.avoidance_enabled:
		# Агент сам скорректирует скорость, чтобы избежать столкновений с другими агентами
		navigation_agent.velocity = intended_velocity
		velocity = navigation_agent.get_velocity()
	else:
		# Иначе просто применяем вычисленную скорость
		velocity = intended_velocity
	if current_config and current_state == State.MINI:
		if is_moving:
			jump_time += delta
			if jump_time > current_config.jump_duration:
				jump_time = 0.0

			var t = jump_time / current_config.jump_duration
			var height = 4.0 * current_config.jump_height * t * (1.0 - t)
			animated_sprite.position.y = sprite_base_y - height
		else:
			jump_time = 0.0
			animated_sprite.position.y = sprite_base_y
	# Двигаем персонажа с помощью стандартного метода move_and_slide()
	move_and_slide()

# Функции для управления анимациями
func play_idle_animation():
	if animated_sprite:
		if current_state == State.NORMAL:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("idle_mini")
func play_walk_animation():
	if animated_sprite:
		if current_state == State.NORMAL:
			animated_sprite.play("walk")
		else:
			animated_sprite.play("walk_mini")
#Функция для обновления направления спрайта
func update_sprite_direction(direction: Vector2):
	if direction.x > 0:
		animated_sprite.flip_h = false
	elif direction.x < 0:
		animated_sprite.flip_h = true

func _interactable_interact(obj: InteractableObject) -> void:
	current_interactable = obj
	print(obj)
	pass # Replace with function body.
#
#func _on_pencil_base_pencil_taken(obj: PencilBase) -> void:
	#print(obj.color)
