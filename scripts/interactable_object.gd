extends Area2D
class_name InteractableObject

@export var default_texture: Texture2D
@export var hover_texture: Texture2D

#signal clicked(obj: InteractableObject)
var is_hovered := false

func _ready():
	$Sprite2D.texture = default_texture
	mouse_entered.connect(_on_mouse_enter)
	mouse_exited.connect(_on_mouse_exit)
	input_event.connect(_on_input_event)
	EventBus.location_change_requested.connect(_on_location_load)
	
func _on_location_load():
	print("ready2")
	$Sprite2D.texture = default_texture
	mouse_entered.connect(_on_mouse_enter)
	mouse_exited.connect(_on_mouse_exit)
	input_event.connect(_on_input_event)

func _on_mouse_enter():
	print("ready3")
	is_hovered = true
	$Sprite2D.texture = hover_texture
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exit():
	print("ready4")
	is_hovered = false
	$Sprite2D.texture = default_texture
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _on_input_event(viewport, event, shape_idx):
	print("ready5")
	if event is InputEventMouseButton and event.pressed:
		EventBus.interactable_interact.emit(self)

func interact(player: Node):
	print("ready6")
	print("Взаимодействие с объектом")
