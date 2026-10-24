extends Node3D

@onready var body = $CharacterBody3D
@onready var model = $CharacterBody3D/Model
@onready var target_visibility_checker = $CharacterBody3D/TargetVisibilityChecker

const CLOSE_ENOUGH = 2

var path = null
var path_i = 0
var path_age = 0
var path_age_limit = 30

var move_input = Vector2.ZERO

@export var team = "bad"
var attack_target = null
var target_visibility_check = false
var target_visivility_age = 0
@export var TRIGGER_DELAY = 30
var trigger_delay = 0

var current_plan = null
var target_plan = null
var plan_delay = 0

func _ready() -> void:
	body.team = team
	_set_target_plan(find_attack_target, 0)

func _stop():
	body.input.set_input("Creep", 0.0)
	move_input = Vector2.ZERO

func _set_target_plan(plan, delay):
	if target_plan != plan:
		target_plan = plan
		plan_delay = delay

func check_if_visible(b):
	if (b.global_position - body.global_position).length() < b.loudness:
		return (b.global_position - body.global_position)
	
	if model.global_basis.z.dot(b.global_position - body.global_position) < 0:
		return false
	
	target_visibility_checker.collision_mask = 0b00000000_00000000_00000000_00000001
	target_visibility_checker.target_position = target_visibility_checker.to_local(b.global_position + (Vector3.UP * target_visibility_checker.position.y))
	target_visibility_checker.force_raycast_update()
	if !target_visibility_checker.is_colliding():
		return (b.global_position - body.global_position)
	return false

func find_attack_target():
	var result = null
	var max_dist =  990.0
	for b in Globals.actors:
		if b != body and !b.dead and b.team != team:
			var r = check_if_visible(b)
			if r:
				var l = r.length()
				if l < max_dist:
					max_dist = l
					result = b
	if attack_target == null and result != null:
		print("FOUND YOU")
	if result != null:
		attack_target = result
		_set_target_plan(fire_at_target, 60)

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
		move_input = Vector2.DOWN
		

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
		move_input = Vector2.ZERO
	else:
		follow_path()

func fire_at_target():
	if attack_target == null:
		_set_target_plan(find_attack_target, 20)
		return
	
	if trigger_delay <= 0:
		body.input.set_input("Fire", 1.0)
		trigger_delay = TRIGGER_DELAY
	else:
		trigger_delay -= 1
	
	if !target_visibility_check:
		_set_target_plan(pursue_target, 60)

func pursue_target():
	move_towards_until_range(1)
	if target_visibility_check:
		_set_target_plan(fire_at_target, 30)

func _update_target_visibility():
	target_visivility_age = 0
	target_visibility_check = false
	
	if attack_target == null:
		return
	
	target_visibility_checker.collision_mask = 0b00000000_00000000_00000000_00000011
	target_visibility_checker.target_position = target_visibility_checker.to_local(attack_target.global_position + (Vector3.UP * target_visibility_checker.position.y))
	target_visibility_checker.force_raycast_update()
	if target_visibility_checker.is_colliding(): # it really should be no matter what
		var b = target_visibility_checker.get_collider()
		if b is CharacterBody3D and b.team != team:
			target_visibility_check = true # TODO: store more info, like if we see the actual target or something valid on the way

func _seperation_input():
	var inp = Vector2.ZERO
	for b in Globals.actors:
		if b != body and !b.dead:
			var v = Globals.flat(b.global_position - body.global_position)
			if v.length() < 1.0:
				inp -= v.normalized() * (1.0 - v.length())
	return inp.rotated(-body.look_angle)

func _physics_process(delta: float) -> void:
	move_input = Vector2.ZERO
	body.input.set_input("Fire", 0.0)
	body.input.tick()
	path_age += 1
	target_visivility_age += 1
	
	if !body.dead:
		if attack_target != null and attack_target.dead:
			attack_target = null
		
		if target_visivility_age < 10:
			_update_target_visibility()
		
		if attack_target != null:
			body.aim_target = attack_target.global_position
		
		if current_plan != target_plan and plan_delay <= 0:
			print("NEW PLAN: ", target_plan.get_method())
			current_plan = target_plan
		else:
			plan_delay -= 1
		
		if current_plan != null:
			current_plan.call()
		
		# wall/character avoidance
		move_input += _seperation_input()
		
		body.input.set_2axis(move_input, "Left", "Right", "Forward", "Back")
	
