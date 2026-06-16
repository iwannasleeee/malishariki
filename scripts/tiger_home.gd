extends Node2D

var tiger_talk_dialogue = [
		{
			"name": "Lini",
			"text": "Привет! Рада тебя видеть.",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
		{
			"name": "Lini",
			"text": "...",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # можно менять анимацию внутри диалога
		},
		{
			"name": "",                # строчка без портрета
			"text": "Где-то вдали залаяла собака.",
		},
	]
var cutscene_after_tiger_talk_comic = "res://scenes/ComicCutscenes/cutscenes/comic_tigers.tscn"
var tiger_talk_dialogue2 = [
		{
			"name": "Lini",
			"text": "Привет! Рада тебя видеть.",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
		{
			"name": "Lini",
			"text": "...",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # можно менять анимацию внутри диалога
		},
		{
			"name": "",                # строчка без портрета
			"text": "Где-то вдали залаяла собака.",
		},
	]
var tiger_talk_dialogue3 = [
		{
			"name": "Lini",
			"text": "Привет! Рада тебя видеть.",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
		{
			"name": "Lini",
			"text": "...",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # можно менять анимацию внутри диалога
		},
		{
			"name": "",                # строчка без портрета
			"text": "Где-то вдали залаяла собака.",
		},
	]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SceneManager.player.setup_for_location({
		"state": "normal",
	})
	EventBus.scene_became_visible.connect(_on_location_load)

func _on_location_load():
	pass

func tiger_talk():
	EventBus.dialogue_started.emit("res://scenes/ui/dialogue/Dialogue.tscn",tiger_talk_dialogue)
	await EventBus.dialogue_finished
	EventBus.comic_cutscene_started.emit(cutscene_after_tiger_talk_comic)
	await EventBus.comic_cutscene_finished
	EventBus.minigame_started.emit("res://scenes/minigames/CakeIsLie/cake_is_lie.tscn")
	UIManager.show_minigame("res://scenes/minigames/CakeIsLie/cake_is_lie.tscn")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
