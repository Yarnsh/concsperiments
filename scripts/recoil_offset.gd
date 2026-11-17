extends Node3D

var transform_amplitude = 1.0
var rotation_amplitude = 1.0

var recoil = 0.0

@export var recoil_per_shot = 0.3

@export var recoil_offset = Vector3.ZERO
@export var recoil_rotation = Vector3.ZERO

@export var spread_offsets : Array[Vector3]
@export var spread_rotations : Array[Vector3]
var spread_offset_idx = 0
var spread_rotation_idx = 0

func shot_fired():
	recoil = min(1.0 + (recoil_per_shot - (randf() * recoil_per_shot)), recoil + recoil_per_shot)
	if !spread_offsets.is_empty():
		spread_offset_idx = (spread_offset_idx + 1) % len(spread_offsets)
	if !spread_rotations.is_empty():
		spread_rotation_idx = (spread_rotation_idx + 1) % len(spread_rotations)

func _process(delta: float) -> void:
	position = recoil_offset * recoil
	rotation = recoil_rotation * recoil
	
	if !spread_offsets.is_empty():
		position += spread_offsets[spread_offset_idx] * recoil
	if !spread_rotations.is_empty():
		rotation += spread_rotations[spread_rotation_idx] * recoil
	
	recoil = move_toward(recoil, 0.0, ((recoil * 1.0) + 1.0) * delta)
