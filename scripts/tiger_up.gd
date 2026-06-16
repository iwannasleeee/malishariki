extends Control

@export var platform_follow_speed: float = 8.0
@export var initial_branch_speed: float = 250.0
@export var branch_speed_increase: float = 10.0
@export var branch_spawn_interval: float = 1.2
@export var survival_time_to_win: float = 30.0
@export var hit_penalty: float = 0.2           # на сколько уменьшается прогресс (0..1)
@export var hit_pause_duration: float = 0.6    # секунд паузы после удара
@export var branch_shift_on_hit: float = 200.0 # на сколько пикселей ветки уходят вверх
@export var texture_normal: Texture2D
@export var texture_hit: Texture2D
@export var bg_speed_factor: float = 0.8

var branch_speed: float
var game_over: bool = false
var won: bool = false
var is_hit: bool = false
var progress: float = 0.0  # 0..1
var invincible_timer: float = 0.0
var bg_tile_height: float = 0.0   # NEW: высота одного тайла фона с учётом scale

@onready var bg_tile_1: TextureRect = $BGLayer/BGTile1   # NEW
@onready var bg_tile_2: TextureRect = $BGLayer/BGTile2   # NEW
@onready var platform: TextureRect = $Platform
@onready var player: TextureRect = $Player
@onready var player_hitbox: ColorRect = $Player/HitBox
@onready var branches_container: Control = $Branches
@onready var spawn_timer: Timer = $BranchSpawnTimer
@onready var progress_bar: ProgressBar = $UI/ProgressBar

const BRANCH_SCENES: Array[PackedScene] = [
	preload("res://scenes/minigames/TigerUp/Branches/branch_1.tscn"),
	preload("res://scenes/minigames/TigerUp/Branches/branch_2.tscn"),
	preload("res://scenes/minigames/TigerUp/branches/branch_3.tscn"),
	preload("res://scenes/minigames/TigerUp/branches/branch_4.tscn"),
	preload("res://scenes/minigames/TigerUp/Branches/branch_5.tscn"),
	preload("res://scenes/minigames/TigerUp/Branches/branch_6.tscn"),
	preload("res://scenes/minigames/TigerUp/Branches/branch_7.tscn"),
	preload("res://scenes/minigames/TigerUp/Branches/branch_8.tscn"),
	
]

const NATIVE_W := 1280.0
const NATIVE_H := 720.0
const BRANCH_DESPAWN_Y := 1600.0

var player_d: Vector2
var player_hit_offset: Vector2
var player_hit_size: Vector2

func _ready() -> void:
	branch_speed = initial_branch_speed

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

	# NEW: расставляем два тайла фона друг над другом
	bg_tile_height = bg_tile_1.texture.get_size().y * bg_tile_1.scale.y
	bg_tile_1.position = Vector2.ZERO
	bg_tile_2.position = Vector2(0.0, -bg_tile_height)

func _process(delta: float) -> void:
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

	_scroll_background(delta)   # NEW

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
		branch.position.y += branch_speed * delta

		if branch.position.y > BRANCH_DESPAWN_Y:
			branch.queue_free()
			continue

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

# NEW: бесшовная вертикальная прокрутка фона двумя тайлами
func _scroll_background(delta: float) -> void:
	var move := branch_speed * bg_speed_factor * delta
	bg_tile_1.position.y += move
	bg_tile_2.position.y += move
	if bg_tile_1.position.y >= bg_tile_height:
		bg_tile_1.position.y -= bg_tile_height * 2.0
	if bg_tile_2.position.y >= bg_tile_height:
		bg_tile_2.position.y -= bg_tile_height * 2.0

func _on_spawn_timer_timeout() -> void:
	if game_over or won:
		return
	var branch_scene: PackedScene = BRANCH_SCENES[randi() % BRANCH_SCENES.size()]
	var branch = branch_scene.instantiate()
	branch.position.y = -400
	branches_container.add_child(branch)

func trigger_hit() -> void:
	is_hit = true
	spawn_timer.stop()

	if texture_hit:
		player.texture = texture_hit

	progress = clamp(progress - hit_penalty, 0.0, 1.0)
	progress_bar.value = progress

	var tween := create_tween()
	for b in branches_container.get_children():
		tween.parallel().tween_property(b, "position:y", b.position.y - branch_shift_on_hit, 0.3)

	tween.parallel().tween_property(bg_tile_1, "position:y", bg_tile_1.position.y - branch_shift_on_hit, 0.3)
	tween.parallel().tween_property(bg_tile_2, "position:y", bg_tile_2.position.y - branch_shift_on_hit, 0.3)

	await tween.finished
	await get_tree().create_timer(hit_pause_duration).timeout

	if texture_normal:
		player.texture = texture_normal

	spawn_timer.start()
	invincible_timer = 0.5
	is_hit = false

func trigger_game_over() -> void:
	game_over = true
	spawn_timer.stop()
	for b in branches_container.get_children():
		b.set_process(false)

func trigger_win() -> void:
	won = true
	spawn_timer.stop()
	for b in branches_container.get_children():
		b.set_process(false)
	EventBus.minigame_finished.emit({})
	UIManager.hide_minigame()
	SceneManager.change_scene("res://scenes/locations/TigerHome.tscn", "TigerEdgeSpawn")
