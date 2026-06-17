extends Node2D

@export var player_scale = 1.0
var on_location_load_dialogue = [
		{
			"name": "Киря",
			"text": "Ой, а вокруг выросло так много цветов! ",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
		{
			"name": "Киря",
			"text": "Может собрать немного в букетик? На лугу особенно красивые выросли.",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
	]
var flowers_collected_dialogue = [
		{
			"name": "Киря",
			"text": "УРА! Теперь точно можно к тигрят. Отправляюсь в лес!!",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
	]	
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
			EventBus.update_quest.emit({
				"id": "flowers",
				"title": "Собрать букет на лугу 1/1",
				"completed": true
			})
			EventBus.dialogue_started.emit("res://scenes/ui/dialogue/Dialogue.tscn", flowers_collected_dialogue)
			await EventBus.dialogue_finished
			await get_tree().create_timer(5.0).timeout
			EventBus.set_quests.emit([])
func _on_location_load():
	EventBus.remove_quest.emit("paint")
	EventBus.update_quest.emit({
		"id": "road",
		"completed": true
	})
	EventBus.dialogue_started.emit("res://scenes/ui/dialogue/Dialogue.tscn", on_location_load_dialogue)
	await EventBus.dialogue_finished
	EventBus.add_quest.emit({
		"id": "flowers",
		"title": "Собрать букет на лугу 0/1",
		"completed": false
	})
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
