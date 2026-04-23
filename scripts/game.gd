# game.gd
extends Node2D

@export var first_location: PackedScene

@onready var main_menu = $UI/MainMenu
@onready var hud = $UI/HUD

# game.gd
func _ready() -> void:
	SceneManager.initialize($World, $Lini)
	EventBus.menu_open_requested.connect(_on_menu_open_requested)
	SceneManager.change_scene("res://scenes/locations/StartScreen.tscn","")
func _on_menu_open_requested() -> void:
	hud.visible = false
	main_menu.visible = true
