extends Node3D

@onready var body = $CharacterBody3D
@onready var model = $CharacterBody3D/Model

var path = null
var path_i = 0

var attack_target = null

func set_path(to):
	var start = NavigationServer3D.map_get_closest_point(Globals.nav.get_navigation_map(), body.global_position)
	var end = NavigationServer3D.map_get_closest_point(Globals.nav.get_navigation_map(), to)
	
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

func follow_path():
	if !path.is_empty():
		body.look_target = path[path_i]
		body.input.set_input("Creep", 1.0)
		body.input.set_2axis(Vector2.DOWN, "Left", "Right", "Forward", "Back")
		
		if body.global_position.distance_to(path[path_i]) < 1.5:
			path_i += 1
		
		if len(path) <= path_i:
			path = null

func _physics_process(delta: float) -> void:
	body.input.tick()
	
	if !body.dead:
		# Test movement
		if path == null:
			body.input.set_input("Creep", 0.0)
			body.input.set_2axis(Vector2.ZERO, "Left", "Right", "Forward", "Back")
			pass # set new target here, or wait
		elif !path.is_empty():
			follow_path()
		
		# test combat
		if Globals.player_body != null:
			attack_target = Globals.player_body
			body.aim_target = attack_target.global_position
	
