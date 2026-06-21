extends Node3D

@onready var gun_offset = $Gun

var _mouse_position = Vector2(0.0, 0.0)
var _total_pitch = 0.0
var sensitivity = 0.3

var cam_dist_max = 8.0
var cam_dist_min = 0.25
var cam_distance = 4.0

var start_position = Vector3.ZERO

func _ready() -> void:
	start_position = position

func _process(delta: float) -> void:
	_update_mouselook()
	position = position.move_toward(start_position, (start_position - position).length() * 3.0 * delta)

func _update_mouselook():
	# Only rotates mouse if the mouse is captured
	#if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
	_mouse_position *= sensitivity
	var yaw = _mouse_position.x
	var pitch = _mouse_position.y
	gun_offset.set_camera_movement(_mouse_position)
	_mouse_position = Vector2(0, 0)
	
	# Prevents looking up/down too far
	pitch = clamp(pitch, -80 - _total_pitch, 80 - _total_pitch)
	_total_pitch += pitch

	rotate_y(deg_to_rad(-yaw))
	rotate_object_local(Vector3(1,0,0), deg_to_rad(-pitch))

func _input(event):
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			_mouse_position = event.relative
