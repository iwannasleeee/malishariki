extends InteractableObject
class_name Papa_Tigr


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	
func interact(player: Node):
		## Формируем сценарий диалога
	#var dialogue = [
		#{
			#"name": "Lini",
			#"text": "Привет! Рада тебя видеть.",
			#"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			#"animation": "talk"        # имя анимации в SpriteFrames
		#},
		#{
			#"name": "Lini",
			#"text": "...",
			#"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			#"animation": "talk"        # можно менять анимацию внутри диалога
		#},
		#{
			#"name": "",                # строчка без портрета
			#"text": "Где-то вдали залаяла собака.",
		#},
	#]
	#
	## Генерируем событие. Укажите точный путь к вашей сцене диалога
	#EventBus.dialogue_started.emit("res://scenes/ui/dialogue/Dialogue.tscn", dialogue)
	#await EventBus.dialogue_finished
	EventBus.minigame_started.emit("res://scenes/minigames/TigerUp/tiger_up.tscn")
