extends Node2D

@onready var main_menu = $UI/MainMenu
@onready var hud = $UI/HUD
@onready var minigame = $UI/Minigame
func _ready() -> void:
	SceneManager.initialize($World, $Lini)
	UIManager.initialize(hud,main_menu,minigame)
	EventBus.menu_open_requested.connect(_on_menu_open_requested)
	UIManager.show_menu_screen("res://scenes/ui/StartScreen.tscn")
	UIManager.show_hud_screen("res://scenes/ui/hud.tscn")

func _on_menu_open_requested() -> void:
	hud.visible = false
	main_menu.visible = true
