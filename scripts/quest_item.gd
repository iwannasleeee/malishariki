extends PanelContainer
 
## Один пункт списка заданий. Вешать на корень сцены QuestItem.tscn
## (PanelContainer -> HBoxContainer -> Check / VBoxContainer(Title, Description))
 
@onready var title_label: Label = $HBoxContainer/VBoxContainer/Title
@onready var desc_label: Label = $HBoxContainer/VBoxContainer/Description
@onready var check: CheckBox = $HBoxContainer/CheckBox
 
func set_data(quest: Dictionary) -> void:
	title_label.text = quest.title
	desc_label.text = quest.get("description", "")
 
	var is_done: bool = quest.get("completed", false)
	check.button_pressed = is_done
	check.disabled = true  # это просто индикатор, не интерактивная галочка
 
	# визуально притушить выполненные задания
	modulate = Color(1, 1, 1, 0.5) if is_done else Color.WHITE
