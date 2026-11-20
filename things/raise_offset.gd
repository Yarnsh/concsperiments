extends Node3D

var transform_amplitude = 0.0
var rotation_amplitude = 0.0

func start_raise():
	transform_amplitude = 1.0
	rotation_amplitude = 1.0

func _process(delta: float) -> void:
	transform_amplitude = move_toward(transform_amplitude, 0.0, 9.5 * delta * (transform_amplitude))
	rotation_amplitude = move_toward(rotation_amplitude, 0.0, 9.5 * delta * (rotation_amplitude))
