extends InteractableObject

signal tiger_talk()

func _ready() -> void:
	super._ready()
	$AnimatedSprite2D.play("idle")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func interact(player: Node):
	tiger_talk.emit()
