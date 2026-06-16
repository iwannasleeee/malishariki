extends InteractableObject
class_name Papa_Tigr

@onready var papa_tigr_sprite: Sprite2D = $PapaTigrSprite
var is_clicked = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	EventBus.scene_became_visible.connect(_on_location_load)
	
func _on_location_load():
	print("test1")
	papa_tigr_sprite.hide()
	print("test2")

func interact(player: Node):
	if is_clicked == true:
		return
	is_clicked = true
		# Формируем сценарий диалога
	var before_tigr_dialogue = [
		{
			"name": "Киря",
			"text": "Вот я и добрался...Но как мне к ним подняться...Я еще не был у них в гостях.",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
		{
			"name": "Киря",
			"text": "Тиги!!",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
		{
			"name": "Киря",
			"text": "Рири-и-и!!",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
		{
			"name": "",                # строчка без портрета
			"text": "Из ниоткуда возникает топот больших ног.",
		},
	]
	var after_tigr_dialogue = [
		{
			"name": "Киря",
			"text": "Ой, здравствуйте, мистер Тигр...В-вы бы смогли позвать Тиги и Рири?...",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
		{
			"name": "",                # строчка без портрета
			"text": "...",
		},
		{
			"name": "Киря",
			"text": "П-пожалуйста...",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
	]
	# Генерируем событие. Укажите точный путь к вашей сцене диалога
	EventBus.dialogue_started.emit("res://scenes/ui/dialogue/Dialogue.tscn", before_tigr_dialogue)
	await EventBus.dialogue_finished
	
	await UIManager.fade_out()
	papa_tigr_sprite.show()
	await get_tree().create_timer(1.5).timeout
	await UIManager.fade_in()
	
	EventBus.dialogue_started.emit("res://scenes/ui/dialogue/Dialogue.tscn", after_tigr_dialogue)
	await EventBus.dialogue_finished
	
	EventBus.minigame_started.emit("res://scenes/minigames/TigerUp/tiger_up.tscn")
