extends Control

@onready var candle: AnimatedSprite2D = $CandleSprite
@onready var trail = $TrailPath
@onready var overlay: ColorRect = $OverlayRect
@onready var label: Label = $BirthdayLabel
@onready var timer: Timer = $SceneTimer

func _ready():
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
	EventBus.minigame_finished.emit({})
	UIManager.hide_minigame()
	EventBus.show_birthday_label.emit()
