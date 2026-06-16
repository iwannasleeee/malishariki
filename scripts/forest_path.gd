extends Node2D

@export var player_scale = 1.0
var on_location_load_dialogue = [
		{
			"name": "Киря",
			"text": "Теперь можно садиться за плакат!!",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
	]
var flowers_collected_dialogue = []	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SceneManager.player.setup_for_location({
		"state": "mini",
		"scale": player_scale
	})
	EventBus.scene_became_visible.connect(_on_location_load)
	EventBus.minigame_finished.connect(_on_minigame_finished)
	
func _on_minigame_finished(result: Dictionary):
	if result.has("result"):
		if result["result"] == "done":
			EventBus.dialogue_started.emit("res://scenes/ui/dialogue/Dialogue.tscn", flowers_collected_dialogue)

func _on_location_load():
	EventBus.dialogue_started.emit("res://scenes/ui/dialogue/Dialogue.tscn", on_location_load_dialogue)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
