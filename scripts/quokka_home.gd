extends Node2D

@onready var bg: AnimatedSprite2D = $Background

var quokka_dialogue = [
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
	EventBus.scene_became_visible.connect(_on_location_load)
	SceneManager.player.hide()

func _on_location_load():
	bg.play("default")
	await get_tree().create_timer(1.0).timeout
	EventBus.dialogue_started.emit("res://scenes/ui/dialogue/Dialogue.tscn",quokka_dialogue)
	await EventBus.dialogue_finished
	EventBus.minigame_started.emit("res://scenes/minigames/CakeIsLie/cake_is_lie.tscn")
	UIManager.show_minigame("res://scenes/minigames/CakeIsLie/cake_is_lie.tscn")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
