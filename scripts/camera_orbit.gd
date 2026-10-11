class_name CameraOrbit
extends Camera3D

var target: Vector3 = Vector3(0, 2.5, 0)
var distance: float = 16.0
var min_distance: float = 6.0
var max_distance: float = 30.0
var yaw: float = 0.35
var pitch: float = 0.42
var min_pitch: float = 0.06
var max_pitch: float = 1.30

var _current_distance: float = 16.0
var _current_target: Vector3 = Vector3(0, 2.5, 0)

func _ready() -> void:
	fov = 55.0
	near = 0.1
	far = 200.0
	_current_distance = distance
	_current_target = target

func _process(delta: float) -> void:
	distance = clamp(distance, min_distance, max_distance)
	var s := 1.0 - exp(-8.0 * delta)
	_current_distance = lerp(_current_distance, distance, s)
	_current_target = _current_target.lerp(target, s)
	var offset := Vector3(
		cos(pitch) * sin(yaw),
		sin(pitch),
		cos(pitch) * cos(yaw)
	) * _current_distance
	global_position = _current_target + offset
	look_at(_current_target, Vector3.UP)

func orbit(relative: Vector2) -> void:
	yaw -= relative.x * 0.006
	pitch = clamp(pitch + relative.y * 0.006, min_pitch, max_pitch)

func zoom_by(factor: float) -> void:
	if factor <= 0.0:
		return
	distance = clamp(distance / factor, min_distance, max_distance)
