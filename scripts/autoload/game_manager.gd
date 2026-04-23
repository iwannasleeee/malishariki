extends Node

# Прогресс
var current_chapter: int = 1
var inventory: Array[String] = []
var visited_locations: Array[String] = []

# Флаги — выполненные действия, триггеры сюжета
var flags: Dictionary = {
	"met_npc_john": false,
	"door_unlocked": false,
}

func set_flag(flag: String, value: bool) -> void:
	flags[flag] = value
	EventBus.flag_changed.emit(flag, value)

func has_item(item: String) -> bool:
	return item in inventory
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
