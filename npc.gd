extends Node3D

@onready var body = $CharacterBody3D

var path = null
var path_i = 0

func _physics_process(delta: float) -> void:
	body.input.tick()
	
	# test movement
	body.look_target = Vector3(5, 0.6, -17)
	#body.input.set_input("Left", 0.1)
	body.input.set_2axis(Vector2.DOWN, "Left", "Right", "Forward", "Back")
	
	if path == null:
		var start = NavigationServer3D.map_get_closest_point(Globals.nav.get_navigation_map(), body.global_position)
		var end = NavigationServer3D.map_get_closest_point(Globals.nav.get_navigation_map(), Vector3(0.0, 3.0, 30.0))
		
		path = NavigationServer3D.map_get_path(
			Globals.nav.get_navigation_map(),
			start,
			end,
			true
		)

		if path.is_empty():
			path = null
		else:
			path_i = 1
			
	elif !path.is_empty():
		body.look_target = path[path_i]
		body.input.set_input("Creep", 1.0)
		body.input.set_2axis(Vector2.DOWN, "Left", "Right", "Forward", "Back")
		
		if body.global_position.distance_to(path[path_i]) < 1.5:
			path_i += 1
		
		if len(path) <= path_i:
			path = []
	
	else:
		body.input.set_input("Creep", 0.0)
		body.input.set_2axis(Vector2.ZERO, "Left", "Right", "Forward", "Back")
