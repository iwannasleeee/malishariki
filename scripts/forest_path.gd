extends Node2D

@export var player_scale = 1.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SceneManager.player.setup_for_location({
		"state": "mini",
		"scale": player_scale
	})
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
