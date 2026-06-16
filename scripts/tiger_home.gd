extends Node2D

var tiger_talk_dialogue1 = [
		{
			"name": "Киря",
			"text": "Ребята!! Представляете, меня сюда поднял ваш папа! ",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
		{
			"name": "Киря",
			"text": "У него такие сильные лапы..",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
		{
			"name": "Киря",
			"text": "Но не в этом суть, я пришел показать свой обещанный плакат!!",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
		{
			"name": "Рири",
			"text": "Ты уже нарисовал его?",
			"portrait": "res://scenes/ui/dialogue/portraits/RiriPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
		{
			"name": "Рири",
			"text": "Так быстро?",
			"portrait": "res://scenes/ui/dialogue/portraits/RiriPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
		{
			"name": "Тиги",
			"text": "Ну-ка, покажи че там.",
			"portrait": "res://scenes/ui/dialogue/portraits/TigiPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
	]
var cutscene_after_tiger_talk_comic = "res://scenes/ComicCutscenes/cutscenes/comic_tigers.tscn"
var tiger_talk_dialogue2 = [
		{
			"name": "Киря",
			"text": "ААААААААААААААААААААААААААА!!!",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
		{
			"name": "Киря",
			"text": "Что ты надела-а-а-ал!",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
		{
			"name": "Тиги",
			"text": "Ой-йёй. Ну я правда не специально. ",
			"portrait": "res://scenes/ui/dialogue/portraits/TigiPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
		{
			"name": "Киря",
			"text": "Ты всегда так!",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
		{
			"name": "Тиги",
			"text": "Ну я всегда потом ещё исправляю. Вот дай уже сюда свой плакат и смотри.",
			"portrait": "res://scenes/ui/dialogue/portraits/TigiPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
	]
var tiger_talk_dialogue3 = [
		{
			"name": "Киря",
			"text": "Я не уверен, что это все исправило... ",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
		{
			"name": "Киря",
			"text": "Со стороны рисунка все равно видно, что он порван!",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
		{
			"name": "Тиги",
			"text": "Хм. Даже не знаю, что еще сделать.",
			"portrait": "res://scenes/ui/dialogue/portraits/TigiPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
		{
			"name": "Рири",
			"text": "Я знаю!",
			"portrait": "res://scenes/ui/dialogue/portraits/RiriPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
		{
			"name": "",                # строчка без портрета
			"text": "Рири показывает руки из-за спины, в которых она держит полароиды с ними с разных годов.",
		},
		{
			"name": "",                # строчка без портрета
			"text": "На всех них есть Квочи.",
		},
		{
			"name": "Рири",
			"text": "Давайте наклеим туда общие фотки!",
			"portrait": "res://scenes/ui/dialogue/portraits/RiriPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
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
	EventBus.dialogue_started.emit("res://scenes/ui/dialogue/Dialogue.tscn",tiger_talk_dialogue1)
	await EventBus.dialogue_finished
	EventBus.comic_cutscene_started.emit(cutscene_after_tiger_talk_comic)
	await EventBus.comic_cutscene_finished
	EventBus.dialogue_started.emit("res://scenes/ui/dialogue/Dialogue.tscn",tiger_talk_dialogue2)
	await EventBus.dialogue_finished
	
	EventBus.dialogue_started.emit("res://scenes/ui/dialogue/Dialogue.tscn",tiger_talk_dialogue3)
	await EventBus.dialogue_finished
	
	SceneManager.change_scene("res://scenes/locations/QuokkaHome.tscn")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
