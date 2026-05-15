extends Control

@onready var name_label: Label = $Panel/MarginContainer/VBoxContainer/NameLabel
@onready var dialogue_text: RichTextLabel = $Panel/MarginContainer/VBoxContainer/DialogueText

var lines: Array = []
var index: int = 0

func start_dialogue(dialogue_data: Array) -> void:
	lines = dialogue_data
	index = 0
	print(dialogue_data)
	show_line()

func show_line() -> void:
	if index < lines.size():
		name_label.text = lines[index].get("name", "")
		dialogue_text.text = lines[index].get("text", "")
	else:
		# Оповещаем шину событий, что диалог окончен
		EventBus.dialogue_finished.emit()



func _on_continue_button_pressed() -> void:
	index += 1
	show_line()
