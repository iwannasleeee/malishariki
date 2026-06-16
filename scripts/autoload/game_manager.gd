#game_manager.gd
extends Node

#LINI BEDROOM
var pencils_goal_count = 10
var collected_pencils: Array[String] = []
var collected_flowers: Array[String] = []

# Флаги — выполненные действия, триггеры сюжета
var flags: Dictionary = {
	"met_npc_john": false,
	"door_unlocked": false,
}

func _ready() -> void:
	EventBus.linibedroom_pencil_taken.connect(_pencil_taken_handler)

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

#LINI BEDROOM

func _pencil_taken_handler(obj: PencilBase):
	if !collected_pencils.has(obj.color_name):
		collected_pencils.append(obj.color_name)
	#var collected_pencils_count = collected_pencils.
	EventBus.update_quest.emit({
		"id":"pencils",
		"description": "Собрано карандашей: {к1}/{к2}"
		.format({
			"к1": collected_pencils.size(),
			"к2": pencils_goal_count
			})
		})
	if collected_pencils.size() == 10:
		EventBus.remove_quest.emit("pencils")
