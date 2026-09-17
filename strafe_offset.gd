extends Node3D

@onready var character = $"../../../.."

var transform_amplitude = 1.0
var rotation_amplitude = 1.0

func _process(delta: float) -> void:
	var strafe_pos = Vector3.ZERO
	strafe_pos.x = character.input_dir.x * 0.1
	strafe_pos.z = character.input_dir.y * 0.1
	position = position.move_toward(strafe_pos, (position - strafe_pos).length() * 10.0 * delta)
	rotation.z = position.x * -2.5
