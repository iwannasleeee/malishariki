# autoload/ui_manager.gd
extends Node

var hud: Control
var main_menu: Control

var current_hud_screen: Control
var current_menu_screen: Control

func initialize(h: Control, m: Control) -> void:
	hud = h
	main_menu = m

# --- MainMenu ---

func show_menu_screen(scene_path: String) -> void:
	_swap_screen(main_menu, scene_path, current_menu_screen)

func hide_menu() -> void:
	main_menu.visible = false

# --- HUD ---

func show_hud_screen(scene_path: String) -> void:
	_swap_screen(hud, scene_path, current_hud_screen)

func hide_hud() -> void:
	hud.visible = false

# --- Внутренняя логика ---

func _swap_screen(container: Control, scene_path: String, current: Control) -> void:
	if current and is_instance_valid(current):
		current.queue_free()

	if scene_path == "":
		container.visible = false
		return

	var packed: PackedScene = load(scene_path)
	var screen := packed.instantiate() as Control
	container.add_child(screen)
	container.visible = true
	
	# Обновляем ссылку на текущий экран
	if container == main_menu:
		current_menu_screen = screen
	else:
		current_hud_screen = screen
