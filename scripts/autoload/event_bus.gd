# autoload/event_bus.gd
extends Node

signal location_change_requested(scene: PackedScene, spawn_name: String)
signal minigame_started(scene: PackedScene)
signal minigame_finished(result: Dictionary)

signal dialogue_started(scene_path: String, dialogue_data: Array)
signal dialogue_finished()

signal paint_started(scene: PackedScene)
signal paint_finished(result: Dictionary)

signal menu_open_requested()
signal interactable_interact()

#Bedroom
signal pencil_taken(obj: PencilBase)

signal comic_cutscene_started(scene: PackedScene)
signal comic_cutscene_finished()
