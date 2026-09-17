extends Node3D

var transform_amplitude = 1.0
var rotation_amplitude = 1.0

var recoil = 0.0
var fast_recoil = 0.0

func shot_fired():
	recoil += 0.3
	fast_recoil += 1.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.z = (recoil + fast_recoil) * 0.0
	position.y = (recoil + fast_recoil) * 0.2
	rotation.x = (recoil + fast_recoil) * 0.9
	rotation.y = (recoil + fast_recoil) * -0.1
	recoil = move_toward(recoil, 0.0, ((recoil * 1.0) + 1.0) * delta)
	fast_recoil = move_toward(fast_recoil, 0.0, ((fast_recoil * 10.0) + 1.0) * delta)
