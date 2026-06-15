# autoload/ui_manager.gd
extends Node

var hud: Control
var main_menu: Control
var minigame: Control
var dialogue_container: Control
var fullscreen_layer: Control

var current_hud_screen: Control
var current_menu_screen: Control
var current_minigame_screen: Control
var current_dialogue_screen: Control
var current_fullscreen: Control
const MINIGAME_TRANSITION = "res://scenes/minigames/MinigameTransition.tscn"

func initialize(h: Control, m: Control, mg: Control, d: Control, fsl: Control) -> void:
	hud = h
	main_menu = m
	minigame = mg
	dialogue_container = d
	fullscreen_layer = fsl
	
	EventBus.minigame_started.connect(show_minigame)
	EventBus.minigame_finished.connect(hide_minigame)
	
	EventBus.dialogue_started.connect(show_dialogue)
	EventBus.dialogue_finished.connect(hide_dialogue)
	
	EventBus.paint_started.connect(show_paint)
	EventBus.paint_finished.connect(hide_paint)
# --- MainMenu ---
func show_menu_screen(scene_path: String) -> void:
	_swap_screen(main_menu, scene_path)

func hide_menu() -> void:
	main_menu.visible = false

# --- HUD ---
func show_hud_screen(scene_path: String) -> void:
	_swap_screen(hud, scene_path)

func hide_hud() -> void:
	hud.visible = false

# --- Minigame ---
func show_minigame(scene_path: String) -> void:
	if current_minigame_screen and is_instance_valid(current_minigame_screen):
		current_minigame_screen.queue_free()

	minigame.visible = true
	get_tree().paused = true
	
	var transition: Control = (load(MINIGAME_TRANSITION) as PackedScene).instantiate()
	transition.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	minigame.add_child(transition)

	await transition.transition_finished  # ждём конца анимации

	transition.queue_free()
	
	var screen: Node = (load(scene_path) as PackedScene).instantiate()
	minigame.add_child(screen)

	var native: Vector2 = Vector2(1280, 720)
	var target: Vector2 = minigame.size
	var s: float = min(target.x / native.x, target.y / native.y)

	screen.scale = Vector2(s, s)
	screen.pivot_offset = Vector2.ZERO
	screen.position = (target - native * s) / 2.0

	# Сбрасываем anchors у самого screen, чтобы он не тянулся
	screen.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	screen.custom_minimum_size = native
	screen.size = native

	current_minigame_screen = screen
	minigame.visible = true

	if screen.has_signal("finished"):
		screen.finished.connect(hide_minigame)

	get_tree().paused = true

func hide_minigame() -> void:
	get_tree().paused = false
	if current_minigame_screen and is_instance_valid(current_minigame_screen):
		current_minigame_screen.queue_free()
	current_minigame_screen = null
	minigame.visible = false

# --- Dialogue ---
func show_dialogue(scene_path: String, dialogue_data: Array) -> void:
	# Метод _swap_screen адаптирован под базовую логику
	_swap_screen(dialogue_container, scene_path)
	
	# Передаем данные в созданный UI-скрипт диалога
	if current_dialogue_screen and current_dialogue_screen.has_method("start_dialogue"):
		current_dialogue_screen.start_dialogue(dialogue_data)
		
	# Для point-and-click часто нужно ставить игру на паузу во время бесед
	get_tree().paused = true

func hide_dialogue() -> void:
	get_tree().paused = false
	_swap_screen(dialogue_container, "") # Очистит контейнер и скроет его
	
func show_paint(scene_path: String) -> void:
	if current_fullscreen and is_instance_valid(current_fullscreen):
		current_fullscreen.queue_free()

	var screen: Node = (load(scene_path) as PackedScene).instantiate()
	fullscreen_layer.add_child(screen)

	current_fullscreen = screen
	fullscreen_layer.visible = true

	if screen.has_signal("finished"):
		screen.finished.connect(hide_paint)

	get_tree().paused = true
	
func hide_paint() -> void:
	get_tree().paused = false
	if current_fullscreen and is_instance_valid(current_fullscreen):
		current_fullscreen.queue_free()
	current_fullscreen = null
	fullscreen_layer.visible = false
	
# --- Внутренняя логика ---
func _swap_screen(container: Control, scene_path: String) -> void:
	# Получаем ссылку на текущий экран этого контейнера
	var current := _get_current(container)
	if current and is_instance_valid(current):
		current.queue_free()

	if scene_path == "":
		container.visible = false
		return

	var packed := load(scene_path)
	if packed == null:
		push_error("UIManager: не удалось загрузить сцену: " + scene_path)
		return
	var screen := (packed as PackedScene).instantiate() as Control
	
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	container.add_child(screen)
	container.visible = true
	_set_current(container, screen)

# Исправляем _get_current (добавляем ветку диалога)
func _get_current(container: Control) -> Control:
	if container == main_menu: return current_menu_screen
	if container == hud: return current_hud_screen
	if container == minigame: return current_minigame_screen
	if container == dialogue_container: return current_dialogue_screen
	return null


# Исправляем _set_current (добавляем ветку диалога)
func _set_current(container: Control, screen: Control) -> void:
	if container == main_menu: current_menu_screen = screen
	elif container == hud: current_hud_screen = screen
	elif container == minigame: current_minigame_screen = screen
	elif container == dialogue_container: current_dialogue_screen = screen
