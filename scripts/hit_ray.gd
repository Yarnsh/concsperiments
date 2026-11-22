extends RayCast3D

var source = null
var tracers = null

func _ready() -> void:
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
			
		get_collider().hit_by_bullet(source)
	
	if tracers != null:
		tracers.emit(dist)
