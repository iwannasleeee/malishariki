extends Control

@onready var sprite := $HoverSprite
signal table_clicked()
var was_clicked = false
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	sprite.visible = false
	mouse_entered.connect(_on_entered)
	mouse_exited.connect(_on_exited)

func _on_entered() -> void:
	sprite.visible = true

func _on_exited() -> void:
	sprite.visible = false


func _gui_input(event: InputEvent) -> void:
	if was_clicked:
		return

	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		_on_clicked()

func _on_clicked() -> void:
	table_clicked.emit()
	was_clicked = true
