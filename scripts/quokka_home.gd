extends Node2D

@onready var bg: AnimatedSprite2D = $Background
@onready var overlay: ColorRect = $OverlayRect
@onready var label: Label = $OverlayRect/BirthdayLabel
var quokka_dialogue = [
		{
			"name": "Киря",
			"text": "А вдруг не понравится?",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
		{
			"name": "Тиги",
			"text": "Да все понравится, не волнуйся!",
			"portrait": "res://scenes/ui/dialogue/portraits/TigiPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
		{
			"name": "Рири",
			"text": "Да-да, понравится!",
			"portrait": "res://scenes/ui/dialogue/portraits/RiriPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
		{
			"name": "Квочи",
			"text": "Что понравится?",
			"portrait": "res://scenes/ui/dialogue/portraits/QuochiPortrait.tscn",
			"animation": "talk"        # можно менять анимацию внутри диалога
		},
		{
			"name": "",                # строчка без портрета
			"text": "Ребята и не заметили, что их друг уже сидит с ним. Квочи выглядит очень заинтересованным.",
		},
		{
			"name": "Киря",
			"text": "Я-я...Ты много слышал?",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
		{
			"name": "Квочи",
			"text": "Не успел, хотя бы хотелось! Что вы скрываете от меня на моем празднике?",
			"portrait": "res://scenes/ui/dialogue/portraits/QuochiPortrait.tscn",
			"animation": "talk"        # можно менять анимацию внутри диалога
		},
		{
			"name": "Тиги",
			"text": "Только лучшие подарки, которые пора тебе отдать. Давай, Киря!",
			"portrait": "res://scenes/ui/dialogue/portraits/TigiPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
		{
			"name": "",                # строчка без портрета
			"text": "Сквозь волнение и тряску Киря отдает плакат в руки Квочи.",
		},
		{
			"name": "",                # строчка без портрета
			"text": "Квочи раскрывает плакат и его глаза расширяются в изумлении.",
		},
		{
			"name": "Квочи",
			"text": "...Это правда мне?",
			"portrait": "res://scenes/ui/dialogue/portraits/QuochiPortrait.tscn",
			"animation": "talk"        # можно менять анимацию внутри диалога
		},
		{
			"name": "Киря",
			"text": "Я правда хотел сделать лучше, но столько всего случилось...Мы пытались вместе его испарвить и даже клеили разные бумажки, а потом фотки!! Но фотки немного слетали, пришлось искать самый крепкий клей у папы Тигра и затем ещё-",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
		{
			"name": "Квочи",
			"text": "Мне очень нравится!! Спасибо!",
			"portrait": "res://scenes/ui/dialogue/portraits/QuochiPortrait.tscn",
			"animation": "talk"        # можно менять анимацию внутри диалога
		},
		{
			"name": "Квочи",
			"text": "Так красиво нарисовано. Ты видимо долго его делал, да? Мне очень приятно.",
			"portrait": "res://scenes/ui/dialogue/portraits/QuochiPortrait.tscn",
			"animation": "talk"        # можно менять анимацию внутри диалога
		},
		{
			"name": "Квочи",
			"text": "Спасибо вам всем, ребята!",
			"portrait": "res://scenes/ui/dialogue/portraits/QuochiPortrait.tscn",
			"animation": "glad"        # можно менять анимацию внутри диалога
		},
		{
			"name": "",                # строчка без портрета
			"text": "Квочи пообещал повесить плакат на стену в своей комнате.",
		},
		{
			"name": "",                # строчка без портрета
			"text": "А теперь пора имениннику задуть свечку.",
		},
	]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.scene_became_visible.connect(_on_location_load)
	SceneManager.player.hide()
	overlay.modulate.a = 0.0
	label.visible = false

func _on_location_load():
	bg.play("default")
	await get_tree().create_timer(1.0).timeout
	EventBus.dialogue_started.emit("res://scenes/ui/dialogue/Dialogue.tscn",quokka_dialogue)
	await EventBus.dialogue_finished
	EventBus.minigame_started.emit("res://scenes/minigames/CakeIsLie/cake_is_lie.tscn")
	UIManager.show_minigame("res://scenes/minigames/CakeIsLie/cake_is_lie.tscn")
	EventBus.show_birthday_label.connect(_start_fadeout)

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
