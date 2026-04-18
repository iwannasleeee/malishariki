extends InteractableObject
class_name PencilBase
@export var color: Color = Color(0x816a59ff)
signal pencil_taken(obj: PencilBase)
func interact(player: Node) -> void:
	pencil_taken.emit(self)
