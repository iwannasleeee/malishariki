extends Area2D
class_name InteractableObject

@export var default_texture: Texture2D
@export var hover_texture: Texture2D

signal clicked(obj: InteractableObject)
var is_hovered := false

func _ready():
	$Sprite2D.texture = default_texture
	mouse_entered.connect(_on_mouse_enter)
	mouse_exited.connect(_on_mouse_exit)
	input_event.connect(_on_input_event)

func _on_mouse_enter():
	is_hovered = true
	$Sprite2D.texture = hover_texture

func _on_mouse_exit():
	is_hovered = false
	$Sprite2D.texture = default_texture

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		clicked.emit(self)

func interact(player: Node):
	print("Взаимодействие с объектом")
