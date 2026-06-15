extends Control

@onready var candle: AnimatedSprite2D = $CandleSprite
@onready var trail = $TrailPath
@onready var overlay: ColorRect = $OverlayRect
@onready var label: Label = $BirthdayLabel
@onready var timer: Timer = $SceneTimer

func _ready():
	overlay.modulate.a = 0.0
	label.visible = false

	candle.play("burning")
	trail.trail_completed.connect(_on_trail_done)

func _on_trail_done():
	trail.queue_free()

	candle.play("off")

	timer.wait_time = 3.0
	timer.one_shot = true
	timer.timeout.connect(_start_fadeout, CONNECT_ONE_SHOT)
	timer.start()

func _start_fadeout():
	var tween = create_tween()
	tween.tween_property(overlay, "modulate:a", 1.0, 1.0)
	tween.tween_callback(_show_label)

func _show_label():
	label.visible = true

func _input(event):
	if label.visible:
		if event is InputEventMouseButton \
		and event.button_index == MOUSE_BUTTON_RIGHT \
		and event.pressed:
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
