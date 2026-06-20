extends RayCast3D

@onready var gun_target = $"../CameraRotator/Gun/Offset/WalkOffset/StrafeOffset/RecoilOffset/GunFinal" # TODO: change this to be more automiatic
@onready var gun = $"../CameraRotator/Gun/Offset/WalkOffset/StrafeOffset/RecoilOffset/GunFinal/gun"

func _process(delta: float) -> void:
	call_deferred("gun_wall_avoid")

func gun_wall_avoid():
	target_position = to_local(gun_target.global_position)
	force_raycast_update()
	
	if is_colliding():
		gun.global_position = get_collision_point()
	else:
		gun.position = Vector3.ZERO
