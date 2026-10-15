extends RayCast3D

func fire():
	force_raycast_update()
	if is_colliding():
		var hit = get_collider().hit_vfx.instantiate()
		get_tree().root.add_child(hit)
		hit.global_position = get_collision_point()
		if abs(get_collision_normal().dot(Vector3.UP)) == 1.0:
			hit.rotation_degrees.x = 90.0
		else:
			hit.look_at(get_collision_point() + get_collision_normal())
		hit.emitting = true
		
		if get_collider().bullet_hole != null:
			var decal = get_collider().bullet_hole.instantiate()
			get_tree().root.add_child(decal)
			decal.global_position = get_collision_point()
			if abs(get_collision_normal().dot(Vector3.UP)) == 1.0:
				decal.rotation_degrees.x = 90.0
			else:
				decal.look_at(get_collision_point() + get_collision_normal())
			
		get_collider().hit_by_bullet()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Fire"):
		fire()
