extends Control

## Список заданий. Принимает массив словарей вида
## {id: int/String, title: String, description: String, completed: bool}
## и перерисовывает пункты через дочернюю сцену QuestItem.tscn.

@export var quest_item_scene: PackedScene  # назначить QuestItem.tscn в инспекторе

@onready var quest_container: VBoxContainer = $TextureRect/MarginContainer/ScrollContainer/QuestContainer

var quests: Array = []

func _ready() -> void:
	EventBus.set_quests.connect(set_quests)
	EventBus.add_quest.connect(add_quest)
	EventBus.complete_quest.connect(complete_quest)
	EventBus.remove_quest.connect(remove_quest)
	EventBus.update_quest.connect(update_quest)
	refresh()

## Полностью заменить список (например, при загрузке сохранения)
func set_quests(new_quests: Array) -> void:
	quests = new_quests
	refresh()

## Добавить одно новое задание
func add_quest(quest: Dictionary) -> void:
	quests.append(quest)
	refresh()

## Отметить задание выполненным по id
func complete_quest(quest_id) -> void:
	for q in quests:
		if q.id == quest_id:
			q.completed = true
	refresh()

func update_quest(quest) -> void:
	for q in quests:
		if q.id == quest.id:
			if quest.has("title"):
				q.title = quest.title
			if quest.has("description"):
				q.description = quest.description
			if quest.has("completed"):
				q.completed = quest.completed
	refresh()

## Удалить задание по id (например, после получения награды)
func remove_quest(quest_id) -> void:
	quests = quests.filter(func(q): return q.id != quest_id)
	refresh()

## Пересобрать UI-список с нуля
func refresh() -> void:
	for child in quest_container.get_children():
		child.queue_free()
	
	if quests.size() == 0:
		hide()
		return
	else:
		show()
	
	for quest in quests:
		var item := quest_item_scene.instantiate()
		quest_container.add_child(item)
		item.set_data(quest)
	
