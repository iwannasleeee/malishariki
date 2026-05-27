extends Control

@onready var name_label: Label = $Panel/MarginContainer/VBoxContainer/NameLabel
@onready var dialogue_text: RichTextLabel = $Panel/MarginContainer/VBoxContainer/DialogueText
@onready var portrait_anchor: Control = $PortraitAnchor

var lines: Array = []
var index: int = 0

var _scene_cache: Dictionary = {}
var _current_portrait: AnimatedSprite2D = null
var _current_portrait_path: String = ""


func start_dialogue(dialogue_data: Array) -> void:
	lines = dialogue_data
	index = 0
	show()
	show_line()


func show_line() -> void:
	if index < lines.size():
		var line: Dictionary = lines[index]
		name_label.text = line.get("name", "")
		dialogue_text.text = line.get("text", "")
		_update_portrait(line)
	else:
		_clear_portrait()
		hide()
		EventBus.dialogue_finished.emit()


func _update_portrait(line: Dictionary) -> void:
	var portrait_path: String = line.get("portrait", "")
	var animation: String = line.get("animation", "idle")

	if portrait_path.is_empty():
		_clear_portrait()
		return

	if portrait_path != _current_portrait_path:
		_load_portrait(portrait_path)

	if _current_portrait and _current_portrait.sprite_frames:
		if _current_portrait.sprite_frames.has_animation(animation):
			_current_portrait.play(animation)


func _load_portrait(path: String) -> void:
	_clear_portrait()

	var scene: PackedScene
	if _scene_cache.has(path):
		scene = _scene_cache[path]
	else:
		if not ResourceLoader.exists(path):
			push_error("Portrait scene not found: " + path)
			return
		scene = load(path)
		_scene_cache[path] = scene

	_current_portrait = scene.instantiate() as AnimatedSprite2D
	if _current_portrait == null:
		push_error("Root node must be AnimatedSprite2D: " + path)
		return

	portrait_anchor.add_child(_current_portrait)
	# Позиция спрайта внутри anchor — если в сцене-заготовке position = Vector2(0,0),
	# то он встанет ровно туда, куда указывает portrait_anchor
	_current_portrait_path = path


func _clear_portrait() -> void:
	if _current_portrait:
		_current_portrait.queue_free()
		_current_portrait = null
	_current_portrait_path = ""


func _on_continue_button_pressed() -> void:
	index += 1
	show_line()
