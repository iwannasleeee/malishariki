# ui/minigame_transition.gd
extends Control

@onready var sprite: AnimatedSprite2D = $CenterContainer/AnimatedSprite2D

func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)
	sprite.play("MinigameTransition")  # запускает покадровую анимацию

func _on_animation_finished() -> void:
	EventBus.transition_finished.emit()
