extends Node3D

@onready var body = $CharacterBody3D
@onready var model = $CharacterBody3D/Model

const CLOSE_ENOUGH = 2

var path = null
var path_i = 0
var path_age = 0
var path_age_limit = 30

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

	if len(path) < 2:
		path = null
	else:
		path_i = 1
	path_age = 0

func follow_path():
	if len(path) >= 2:
		while len(path) > path_i and body.global_position.distance_to(path[path_i]) < CLOSE_ENOUGH:
			path_i += 1
		
		if len(path) <= path_i:
			path = null
			return
		
		body.look_target = path[path_i]
		body.input.set_input("Creep", 1.0)
		body.input.set_2axis(Vector2.DOWN, "Left", "Right", "Forward", "Back")
		

func move_to_point_range(dist):
	if attack_target == null:
		return
	
	if path_age > path_age_limit:
		set_path(attack_target.global_position + ((body.global_position - attack_target.global_position).normalized() * dist))
	
	if path == null or path.is_empty(): # Couldn't figure out where to move
		body.input.set_input("Creep", 0.0)
		body.input.set_2axis(Vector2.ZERO, "Left", "Right", "Forward", "Back")
	else:
		follow_path()

func move_towards_until_range(dist):
	if attack_target == null:
		return
	
	if path_age > path_age_limit:
		set_path(attack_target.global_position)
	
	if (body.global_position - attack_target.global_position).length() < dist:
		path = null
	
	if path == null or path.is_empty(): # Couldn't figure out where to move
		body.input.set_input("Creep", 0.0)
		body.input.set_2axis(Vector2.ZERO, "Left", "Right", "Forward", "Back")
	else:
		follow_path()

func move_to_range(dist):
	if attack_target == null:
		return
	
	if (body.global_position - attack_target.global_position).length() < dist:
		move_to_point_range(dist)
	else:
		move_towards_until_range(dist)

func move_to_random():
	if path_age > path_age_limit:
		set_path(NavigationServer3D.map_get_random_point(Globals.nav.get_navigation_map(), 1, true))
	
	if path == null or path.is_empty(): # Couldn't figure out where to move
		body.input.set_input("Creep", 0.0)
		body.input.set_2axis(Vector2.ZERO, "Left", "Right", "Forward", "Back")
	else:
		follow_path()

func _physics_process(delta: float) -> void:
	body.input.tick()
	path_age += 1
	
	if !body.dead:
		# Test movement
		move_to_random()
		
		# test combat
		if Globals.player_body != null:
			attack_target = Globals.player_body
			body.aim_target = attack_target.global_position
	
