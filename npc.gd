extends Node3D

@onready var body = $CharacterBody3D
@onready var model = $CharacterBody3D/Model
@onready var target_visibility_checker = $CharacterBody3D/TargetVisibilityChecker

const CLOSE_ENOUGH = 2

var path = null
var path_i = 0
var path_age = 0
var path_age_limit = 30

var attack_target = null
var target_visibility_check = false
var target_visivility_age = 0
@export var TRIGGER_DELAY = 30
var trigger_delay = 0

func _stop():
	body.input.set_input("Creep", 0.0)
	body.input.set_2axis(Vector2.ZERO, "Left", "Right", "Forward", "Back")

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
		_stop()
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
		_stop()
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

func fire_at_target():
	if attack_target == null:
		return
	
	if trigger_delay <= 0 and target_visibility_check:
		print("BANG!")
		body.input.set_input("Fire", 1.0)
		trigger_delay = TRIGGER_DELAY
	else:
		trigger_delay -= 1

func attack():
	if !target_visibility_check:
		move_towards_until_range(1)
	else:
		_stop()
		fire_at_target()

func _update_target_visibility():
	target_visivility_age = 0
	target_visibility_check = false
	
	if attack_target == null:
		return
	
	target_visibility_checker.target_position = target_visibility_checker.to_local(attack_target.global_position + (Vector3.UP * target_visibility_checker.position.y))
	target_visibility_checker.force_raycast_update()
	if target_visibility_checker.is_colliding(): # it really should be no matter what
		var b = target_visibility_checker.get_collider()
		if b is CharacterBody3D: # TODO: check if thing we see is on our team or not, and that its actually a character
			target_visibility_check = true # TODO: store more info, like if we see the actual target or something valid on the way

func _physics_process(delta: float) -> void:
	body.input.set_input("Fire", 0.0)
	body.input.tick()
	path_age += 1
	target_visivility_age += 1
	
	if !body.dead:
		if target_visivility_age < 10:
			_update_target_visibility()
		
		# Test movement
		attack()
		
		# test combat
		if Globals.player_body != null:
			attack_target = Globals.player_body
			body.aim_target = attack_target.global_position
	
