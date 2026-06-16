extends Node2D

@onready var pencils: Node2D = $Pencils

@onready var shelf: InteractableObject = $shelf
@onready var box: InteractableObject = $box

var total_pencils_count = 10
# Called when the node enters the scene tree for the first time.
var is_paint_able = false
var is_tumba_completed = false
var is_box_completed = false
var is_pencils_collected = false

var can_lini_go = false

var paint_able_dialogue = [
		{
			"name": "Lini",
			"text": "Привет! Рада тебя видеть.",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
		{
			"name": "Lini",
			"text": "...",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # можно менять анимацию внутри диалога
		},
		{
			"name": "",                # строчка без портрета
			"text": "Где-то вдали залаяла собака.",
		},
	]
var initial_dialogue = [
		{
			"name": "Lini",
			"text": "Привет! Рада тебя видеть.",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
		{
			"name": "Lini",
			"text": "...",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # можно менять анимацию внутри диалога
		},
		{
			"name": "",                # строчка без портрета
			"text": "Где-то вдали залаяла собака.",
		},
	]
var have_no_box_dialogue = [
		{
			"name": "Lini",
			"text": "Привет! Рада тебя видеть.",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
		{
			"name": "Lini",
			"text": "...",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # можно менять анимацию внутри диалога
		},
		{
			"name": "",                # строчка без портрета
			"text": "Где-то вдали залаяла собака.",
		},
	]
var have_no_tapes_dialogue = [
		{
			"name": "Lini",
			"text": "Привет! Рада тебя видеть.",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
		{
			"name": "Lini",
			"text": "...",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # можно менять анимацию внутри диалога
		},
		{
			"name": "",                # строчка без портрета
			"text": "Где-то вдали залаяла собака.",
		},
	]
var have_no_pencils_dialogue = [
		{
			"name": "Lini",
			"text": "Привет! Рада тебя видеть.",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
		{
			"name": "Lini",
			"text": "...",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # можно менять анимацию внутри диалога
		},
		{
			"name": "",                # строчка без портрета
			"text": "Где-то вдали залаяла собака.",
		},
	]
var paint_done_dialogue = [
		{
			"name": "Lini",
			"text": "Привет! Рада тебя видеть.",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
		{
			"name": "Lini",
			"text": "...",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # можно менять анимацию внутри диалога
		},
		{
			"name": "",                # строчка без портрета
			"text": "Где-то вдали залаяла собака.",
		},
	]
var lini_wanna_go_but_he_cant_dialogue = [
		{
			"name": "Lini",
			"text": "Привет! Рада тебя видеть.",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # имя анимации в SpriteFrames
		},
		{
			"name": "Lini",
			"text": "...",
			"portrait": "res://scenes/ui/dialogue/portraits/LiniPortrait.tscn",
			"animation": "talk"        # можно менять анимацию внутри диалога
		},
		{
			"name": "",                # строчка без портрета
			"text": "Где-то вдали залаяла собака.",
		},
	]

func _ready() -> void:
	total_pencils_count = pencils.get_children().size()
	#pass
	#EventBus.location_change_requested.emit()
	EventBus.scene_became_visible.connect(_on_location_loaded)
	
	EventBus.add_quest.emit({
		"id": "pencils",
		"title": "Собери карандаши сын собаки",
		"description": "Собрано: 0/10",
		"completed": false
		})
	
	EventBus.linibedroom_pencil_taken.connect(_pencil_taken_handler)
	EventBus.paint_finished.connect(_paint_finished_handler)

func _on_location_loaded():	
	EventBus.dialogue_started.emit("res://scenes/ui/dialogue/Dialogue.tscn",initial_dialogue)
	EventBus.minigame_finished.connect(_minigame_finished_handler)

func check_for_able_paint():
	if is_box_completed and is_tumba_completed and is_pencils_collected:
		EventBus.dialogue_started.emit("res://scenes/ui/dialogue/Dialogue.tscn",paint_able_dialogue)
		is_paint_able = true

func _pencil_taken_handler(obj: PencilBase):
	if !GameManager.collected_pencils.has(obj.color_name):
		GameManager.collected_pencils.append(obj.color_name)
	#var collected_pencils_count = collected_pencils.
	EventBus.update_quest.emit({
		"id":"pencils",
		"description": "Собрано карандашей: {к1}/{к2}"
		.format({
			"к1": GameManager.collected_pencils.size(),
			"к2": total_pencils_count
			})
		})
		
	if GameManager.collected_pencils.size() == 10:
		EventBus.update_quest.emit({
			"id":"pencils",
			"completed": true,
		})
		is_pencils_collected = true
		check_for_able_paint()

func _minigame_finished_handler(result: Dictionary):
	if result.has("id"):
		if result["id"] == "tumba":
			is_tumba_completed = true
			shelf.hide()
			check_for_able_paint()
		if result["id"] == "books":
			is_box_completed = true
			box.hide()
			check_for_able_paint()


func _on_paint_button_paint_button_click() -> void:
	if not is_box_completed:
		EventBus.dialogue_started.emit("res://scenes/ui/dialogue/Dialogue.tscn",have_no_box_dialogue)
		return
	if not is_tumba_completed:
		EventBus.dialogue_started.emit("res://scenes/ui/dialogue/Dialogue.tscn",have_no_tapes_dialogue)
		return
	if not is_pencils_collected:
		EventBus.dialogue_started.emit("res://scenes/ui/dialogue/Dialogue.tscn",have_no_pencils_dialogue)
		return

	EventBus.paint_started.emit("res://scenes/minigames/Paint/Paint.tscn")

func _paint_finished_handler(result: Dictionary) -> void:
	if not can_lini_go:
		if result.has("result"):
			if result["result"] == "done":
				can_lini_go = true
		EventBus.dialogue_started.emit("res://scenes/ui/dialogue/Dialogue.tscn",paint_done_dialogue)


func _on_door_lini_wanna_go(door) -> void:
	var target_scene = door.target_scene
	var spawn_point_name = door.spawn_point_name
	if can_lini_go:
		SceneManager.change_scene(target_scene, spawn_point_name)
		return
	EventBus.dialogue_started.emit("res://scenes/ui/dialogue/Dialogue.tscn",lini_wanna_go_but_he_cant_dialogue)
