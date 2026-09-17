extends Node3D

var transform_amplitude = 1.0
var rotation_amplitude = 1.0

var clamber_target = 0.0

func trigger_clamber(clamb_amount):
	clamber_target = max(clamber_target, clamb_amount)

func _process(delta: float) -> void:
	position = position.move_toward(clamber_target * Vector3.DOWN * 1.5, (position - (clamber_target * Vector3.DOWN * 1.0)).length() * 3.0 * delta)
	rotation = rotation.move_toward(clamber_target * Vector3(0.0, 2.0, 2.0), (rotation - (clamber_target * Vector3(0.0, 2.0, 2.0))).length() * 5.0 * delta)
	clamber_target = move_toward(clamber_target, 0.0, 1.5 * delta)
