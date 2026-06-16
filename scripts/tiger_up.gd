extends Control

@export var platform_follow_speed: float = 8.0
@export var initial_branch_speed: float = 250.0
@export var branch_speed_increase: float = 10.0
@export var branch_spawn_interval: float = 1.2
@export var survival_time_to_win: float = 30.0
@export var hit_penalty: float = 0.2           # на сколько уменьшается прогресс (0..1)
@export var hit_pause_duration: float = 1.5    # секунд паузы после удара
@export var branch_shift_on_hit: float = 200.0 # на сколько пикселей ветки уходят вверх
@export var texture_normal: Texture2D
@export var texture_hit: Texture2D

var branch_speed: float
var game_over: bool = false
var won: bool = false
var is_hit: bool = false
var progress: float = 0.0  # 0..1
var invincible_timer: float = 0.0

@onready var bg: TextureRect = $BG
@onready var platform: TextureRect = $Platform
@onready var player: TextureRect = $Player
@onready var player_hitbox: ColorRect = $Player/HitBox
@onready var branches_container: Control = $Branches
@onready var spawn_timer: Timer = $BranchSpawnTimer
@onready var timer_label: Label = $UI/TimerLabel
@onready var game_over_label: Label = $UI/GameOverLabel
@onready var progress_bar: ProgressBar = $UI/ProgressBar

const BRANCH_SCENES: Array[PackedScene] = [
	preload("res://scenes/minigames/TigerUp/Branches/branch_1.tscn"),
]

const NATIVE_W := 1280.0
const NATIVE_H := 720.0
const BG_SCROLL_SPEED := 300.0

var bg_offset: float = 0.0
var player_d: Vector2
var player_hit_offset: Vector2
var player_hit_size: Vector2

func _ready() -> void:
	branch_speed = initial_branch_speed
	game_over_label.visible = false

	progress_bar.min_value = 0.0
	progress_bar.max_value = 1.0
	progress_bar.value = 0.0

	spawn_timer.wait_time = branch_spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.autostart = true
	spawn_timer.start()

	player_d = player.position - platform.position
	player_hit_offset = player_hitbox.position
	player_hit_size = player_hitbox.size * player_hitbox.scale
	player_hitbox.visible = false

	if texture_normal:
		player.texture = texture_normal

func _process(delta: float) -> void:
	bg_offset += BG_SCROLL_SPEED * delta

	# Во время удара и после победы/поражения ничего не делаем
	if game_over or won or is_hit:
		return
	
	if invincible_timer > 0.0:
		invincible_timer -= delta
	
	var mouse_x := get_local_mouse_position().x
	var half_player := player.size.x * 0.5
	var target_x: float = clamp(mouse_x - half_player, 0.0, NATIVE_W - player.size.x)
	player.position.x = lerp(player.position.x, target_x, platform_follow_speed * delta)
	platform.position.x = player.position.x - player_d.x

	branch_speed += branch_speed_increase * delta

	# Прогресс растёт со временем
	progress = clamp(progress + delta / survival_time_to_win, 0.0, 1.0)
	progress_bar.value = progress

	if progress >= 1.0:
		trigger_win()
		return

	var player_rect := Rect2(
		player.position + player_hit_offset,
		player_hit_size
	)

	for branch in branches_container.get_children():
		var branch_rect := Rect2(
			branch.position + branch.hit_offset,
			branch.hit_size
		)
		if player_rect.intersects(branch_rect):
			if invincible_timer > 0.0:
				pass
			elif player_rect.intersects(branch_rect):
				trigger_hit()
				return
			return

func _on_spawn_timer_timeout() -> void:
	if game_over or won:
		return
	var branch_scene: PackedScene = BRANCH_SCENES[randi() % BRANCH_SCENES.size()]
	var branch = branch_scene.instantiate()
	branch.speed = branch_speed
	branch.position.y = -400
	branches_container.add_child(branch)

func trigger_hit() -> void:
	is_hit = true
	spawn_timer.stop()

	if texture_hit:
		player.texture = texture_hit

	progress = clamp(progress - hit_penalty, 0.0, 1.0)
	progress_bar.value = progress

	if progress <= 0.0:
		trigger_game_over()
		return

	# Сдвигаем все ветки вверх и останавливаем
	var tween := create_tween()
	for b in branches_container.get_children():
		b.set_process(false)
		tween.parallel().tween_property(b, "position:y", b.position.y - branch_shift_on_hit, 0.3)

	await tween.finished
	await get_tree().create_timer(hit_pause_duration).timeout

	if texture_normal:
		player.texture = texture_normal

	for b in branches_container.get_children():
		b.set_process(true)

	spawn_timer.start()
	invincible_timer = 0.5
	is_hit = false

func trigger_game_over() -> void:
	game_over = true
	spawn_timer.stop()
	for b in branches_container.get_children():
		b.set_process(false)
	game_over_label.text = "Game Over"
	game_over_label.visible = true

func trigger_win() -> void:
	won = true
	spawn_timer.stop()
	for b in branches_container.get_children():
		b.set_process(false)
	EventBus.minigame_finished.emit({})
	UIManager.hide_minigame()
	SceneManager.change_scene("res://scenes/locations/TigerHome.tscn", "TigerEdgeSpawn")
