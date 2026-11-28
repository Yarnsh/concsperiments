extends RayCast3D

var source = null
var tracers = null

var bullet_impact_noise_params = PhysicsShapeQueryParameters3D.new()

func _ready() -> void:
	bullet_impact_noise_params.collision_mask = 0b00000000_00000000_00000000_00001000
	bullet_impact_noise_params.shape = SphereShape3D.new()
	bullet_impact_noise_params.shape.radius = 5.0
	tracers = get_node_or_null("Tracers")

func fire():
	force_raycast_update()
	var dist = -1
	if is_colliding():
		dist = (get_collision_point().distance_to(global_position))
		
		var hit = get_collider().hit_vfx.instantiate()
		get_tree().root.add_child(hit)
		hit.global_position = get_collision_point()
		if get_collision_normal().dot(Vector3.UP) == 1.0:
			hit.rotation_degrees.x = 90.0
		elif get_collision_normal().dot(Vector3.UP) == -1.0:
			hit.rotation_degrees.x = -90.0
		else:
			hit.look_at(get_collision_point() + get_collision_normal())
		hit.emitting = true
		
		if get_collider().bullet_hole != null:
			var decal = get_collider().bullet_hole.instantiate()
			get_tree().root.add_child(decal)
			decal.global_position = get_collision_point()
			if get_collision_normal().dot(Vector3.UP) == 1.0:
				decal.rotation_degrees.x = 90.0
			elif get_collision_normal().dot(Vector3.UP) == -1.0:
				decal.rotation_degrees.x = -90.0
			else:
				decal.look_at(get_collision_point() + get_collision_normal())
		
		var hit_info = {
			"source": source,
			"point": get_collision_point(),
			"normal": get_collision_normal(),
			"direction": (get_collision_point() - global_position).normalized(),
		}
		get_collider().hit_by_bullet(hit_info)
		
		#  bullet impact noise
		bullet_impact_noise_params.transform.origin = get_collision_point()
		var noise_results = get_world_3d().get_direct_space_state().intersect_shape(bullet_impact_noise_params)
		for n in noise_results:
			n["collider"].noise_alert({"source": source, "type": "bullet_impact"})
	
	if tracers != null:
		tracers.emit(dist)
