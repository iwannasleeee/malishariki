extends InteractableObject
class_name Paint_Button

signal paint_button_click
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()

func interact(player: Node) -> void:
	paint_button_click.emit()
