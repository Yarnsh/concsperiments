extends RayCast3D

@onready var body = $".."

func _process(delta: float) -> void:
	call_deferred("gun_wall_avoid")

func gun_wall_avoid():
	target_position = to_local(body.camera.gun_offset.muzzle.global_position)
	force_raycast_update()
	
	if is_colliding():
		body.camera.gun_offset.muzzle_offset.global_position = get_collision_point() + (-body.camera.gun_offset.muzzle.global_position + body.camera.gun_offset.muzzle_offset_p.global_position)
	else:
		body.camera.gun_offset.muzzle_offset.position = Vector3.ZERO
