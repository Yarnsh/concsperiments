extends RayCast3D

@onready var hit_effect = load("res://concrete_hit_effect.tscn")
@onready var hit_decal = load("res://concrete_bullet_hole_decal.tscn") # TODO: pick this based on what material we hit

func fire():
	force_raycast_update()
	if is_colliding():
		var hit = hit_effect.instantiate()
		var decal = hit_decal.instantiate()
		get_tree().root.add_child(hit)
		get_tree().root.add_child(decal)
		hit.global_position = get_collision_point()
		decal.global_position = get_collision_point()
		if get_collision_normal() == Vector3.UP:
			hit.rotation_degrees.x = 90.0
			decal.rotation_degrees.x = 90.0
		else:
			hit.look_at(get_collision_point() + get_collision_normal())
			decal.look_at(get_collision_point() + get_collision_normal())
		hit.emitting = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Fire"):
		fire()
