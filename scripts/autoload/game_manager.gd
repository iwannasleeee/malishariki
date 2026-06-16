#game_manager.gd
extends Node

#LINI BEDROOM
#var pencils_goal_count = 10
var collected_pencils: Array[String] = []
var collected_flowers: Array[String] = []

# Флаги — выполненные действия, триггеры сюжета
var flags: Dictionary = {
	"met_npc_john": false,
	"door_unlocked": false,
}

func set_flag(flag: String, value: bool) -> void:
	flags[flag] = value
	EventBus.flag_changed.emit(flag, value)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# ==== Сохранённый рисунок (Paint) ====
var paint_drawing: Image = null

func save_paint_drawing(img: Image) -> void:
	paint_drawing = img.duplicate()

func has_paint_drawing() -> bool:
	return paint_drawing != null

func get_paint_drawing() -> Image:
	return paint_drawing
