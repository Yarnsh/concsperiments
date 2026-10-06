extends RayCast3D

@onready var laser = $laser

func _process(delta: float) -> void:
	force_raycast_update()
	if is_colliding():
		var hit = get_collision_point()
		laser.scale.z = (hit - global_position).length()
	else:
		laser.scale.z = 100.0
