extends InteractableObject

signal tiger_talk()
var is_clicked = false
func _ready() -> void:
	super._ready()
	$AnimatedSprite2D.play("idle")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func interact(player: Node):
	if is_clicked == true:
		return
	is_clicked = true
	tiger_talk.emit()
