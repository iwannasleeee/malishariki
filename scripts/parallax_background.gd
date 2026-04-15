extends ParallaxBackground

@export var base_drift_speed: float = -15.0      # базовая скорость дрейфа (пикс/сек) для слоя с motion_scale=1
@export var camera_influence: float = 0.3       # сила влияния движения камеры на дрейф
@export var normalize_speed: float = 200.0      # скорость камеры, при которой влияние максимально

var last_scroll_offset: Vector2 = Vector2.ZERO

func _ready():
	last_scroll_offset = scroll_offset

func _process(delta: float):		
	for child in get_children():
		if child is ParallaxLayer and child.name.begins_with("SkyLayer"):
			child.motion_offset.x += base_drift_speed * child.motion_scale.x * delta
			
			# Бесконечность через mirroring
			if child.motion_mirroring.x > 0:
				var mirror = child.motion_mirroring.x
				if abs(child.motion_offset.x) > mirror:
					child.motion_offset.x = fmod(child.motion_offset.x, mirror)
