extends Control

## Испускается после последней панели — родитель решает что делать дальше.
signal cutscene_finished

## Заполняй в инспекторе через drag-and-drop, порядок = порядок кадров.
@export var panels: Array[Texture2D] = []

@onready var _image: TextureRect = $PanelImage

var _index: int = 0


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_STOP
	_show_current()


## Запустить / перезапустить катсцену с первого кадра.
func play() -> void:
	_index = 0
	#show()
	_show_current()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and event.pressed:
		_advance()


func _advance() -> void:
	_index += 1
	if _index >= panels.size():
		EventBus.comic_cutscene_finished.emit()
		return
	_show_current()


func _show_current() -> void:
	if panels.is_empty():
		push_warning("ComicCutscene: массив panels пуст!")
		return
	_image.texture = panels[_index]
