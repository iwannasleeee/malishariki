extends Control

@export_file("ForestPath.tscn") var game_scene_path: String
@export var spawn_point_name: String = "SpawnBed"
@onready var play_button: Button = $CenterContainer/VBoxContainer/PlayButton
@onready var settings_button: Button = $CenterContainer/VBoxContainer/SettingsButton
@onready var info_button: Button = $CenterContainer/VBoxContainer/InfoButton
@onready var exit_button: Button = $CenterContainer/VBoxContainer/ExitButton

func _ready():
	# Настраиваем курсоры для всех кнопок
	for button in get_tree().get_nodes_in_group("menu_buttons"):
		button.mouse_entered.connect(_on_button_hover)
		button.mouse_exited.connect(_on_button_normal)
		
	play_button.pressed.connect(_on_play_button_pressed)
	
	if exit_button:
		exit_button.pressed.connect(_on_quit_button_pressed)


func _on_play_button_pressed():
	# Загружаем и переходим на игровую сцену
	if game_scene_path:
		SceneManager.change_scene(game_scene_path, spawn_point_name)
		UIManager.hide_menu()
	else:
		print("Ошибка: путь к сцене не указан!")

func _on_quit_button_pressed():
	get_tree().quit()

func _on_button_hover():
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	
func _on_button_normal():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	
	
