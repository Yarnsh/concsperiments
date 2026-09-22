extends Node3D

@onready var character = $"../../../.."

var transform_amplitude = 0.0
var rotation_amplitude = 0.0
var actual_f = 0.0

func _ready() -> void:
	rotation.z = 0.9
	position.x = -0.1

func _process(delta: float) -> void:
	var f = (1.0 - character.to_floor_fraction()) * 2.0
	if !character.walk_shape.disabled:
		f = 0.0
	actual_f = move_toward(actual_f, f, 3.5 * delta)
	
	transform_amplitude = actual_f
	rotation_amplitude = actual_f
