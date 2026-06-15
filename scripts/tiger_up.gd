extends Control

# Настройки — подбирай под свою игру
@export var platform_follow_speed: float = 8.0
@export var initial_branch_speed: float = 150.0
@export var branch_speed_increase: float = 2.0   # на сколько px/sec прибавляется в секунду
@export var branch_spawn_interval: float = 1.2
@export var survival_time_to_win: float = 30.0

var branch_speed: float
var game_over: bool = false
var won: bool = false
var elapsed_time: float = 0.0
var player_offset_y: float

@onready var platform: Sprite2D = $World/Platform
@onready var player: Area2D = $World/Player
@onready var player_sprite: Sprite2D = $World/Player/Sprite2D
@onready var anim: AnimatedSprite2D = $World/Player/AnimationPlayer
@onready var branches_container: Node2D = $World/Branches
@onready var spawn_timer: Timer = $BranchSpawnTimer
@onready var timer_label: Label = $UI/TimerLabel
@onready var game_over_label: Label = $UI/GameOverLabel

var platform_size: Vector2 = Vector2(0,0)
# --- Несколько сцен веток ---
const BRANCH_SCENES: Array[PackedScene] = [
	preload("res://scenes/minigames/TigerUp/branches/branch_1.tscn"),
	preload("res://scenes/minigames/TigerUp/branches/branch_2.tscn"),
	preload("res://scenes/minigames/TigerUp/branches/branch_3.tscn"),
	preload("res://scenes/minigames/TigerUp/branches/branch_4.tscn"),
	preload("res://scenes/minigames/TigerUp/branches/branch_5.tscn"),
	preload("res://scenes/minigames/TigerUp/branches/branch_6.tscn"),
	preload("res://scenes/minigames/TigerUp/branches/branch_7.tscn"),
	preload("res://scenes/minigames/TigerUp/branches/branch_8.tscn"),
]


func _ready() -> void:
	platform_size = platform.texture.get_size()
	branch_speed = initial_branch_speed
	spawn_timer.wait_time = branch_spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	player.area_entered.connect(_on_player_area_entered)

	game_over_label.visible = false

	# запоминаем смещение персонажа относительно платформы по Y
	player_offset_y = player.position.y - platform.position.y


func _process(delta: float) -> void:
	$ParallaxBackground/ParallaxLayer.motion_offset += Vector2(0, 10 * delta)

	if game_over or won:
		return

	# --- движение платформы за курсором, ограниченное границами игрока ---
		
	var mouse_x: float = $World.get_local_mouse_position().x
	# половина ширины спрайта игрока (с учётом масштаба)
	var half_w: float = (player_sprite.texture.get_width() * 0.5) * player_sprite.scale.x * player.scale.x

	
	var screen_w: float = 1280.0  # нативное разрешение миниигры
	var target_x: float = clamp(mouse_x, half_w, screen_w - half_w)

	platform.position.x = lerp(platform.position.x, target_x - platform_size.x * 0.5 + 120, platform_follow_speed * delta)

	# персонаж всегда "приклеен" к платформе в одной и той же точке
	player.position.x = platform.position.x + platform_size.x * 0.5 - 120 #ХАРДКОД!
	player.position.y = platform.position.y + player_offset_y + 50

	# --- нарастание сложности ---
	branch_speed += branch_speed_increase * delta

	# --- таймер выживания ---
	elapsed_time += delta
	timer_label.text = "%.1f" % elapsed_time

	if elapsed_time >= survival_time_to_win:
		trigger_win()


func _on_spawn_timer_timeout() -> void:
	if game_over or won:
		return

	# случайная сцена ветки из массива
	var branch_scene: PackedScene = BRANCH_SCENES[randi() % BRANCH_SCENES.size()]
	var branch: Area2D = branch_scene.instantiate()
	branch.speed = branch_speed

	var screen_w: float = get_viewport_rect().size.x
	branch.position.y = -100

	branches_container.add_child(branch)


func _on_player_area_entered(_area: Area2D) -> void:
	if game_over or won:
		return
	trigger_game_over()


func trigger_game_over() -> void:
	game_over = true
	spawn_timer.stop()

	# останавливаем все ветки
	for b in branches_container.get_children():
		b.set_process(false)

	# анимация смерти персонажа
	anim.play("death")

	# платформа чуть проседает вниз
	var tween := create_tween()
	tween.tween_property(platform, "position:y", platform.position.y + 30, 0.3)

	game_over_label.text = "Game Over\nВремя: %.1f сек" % elapsed_time
	game_over_label.visible = true


func trigger_win() -> void:
	won = true
	spawn_timer.stop()

	for b in branches_container.get_children():
		b.set_process(false)

	game_over_label.text = "Победа!"
	game_over_label.visible = true
