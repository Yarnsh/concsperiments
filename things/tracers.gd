extends Node3D

var emitters = []
var next = 0

func _ready() -> void:
	for c in get_children():
		emitters.append(c)

func emit(distance):
	if distance > 0:
		emitters[next].lifetime = min(0.3, distance / emitters[next].initial_velocity_min)
	else:
		emitters[next].lifetime = 0.3
	emitters[next].emitting = true
	next = (next+1)%len(emitters)
