extends CharacterBody3D

@onready var camera = $CameraRotator
@onready var gun = $CameraRotator/Gun

@onready var walk_shape = $WalkShape
@onready var jump_shape = $JumpShape
@onready var jump_recovery_cast = $JumpRecoveryCast
@onready var floor_cast_center = $FloorCastCenter
@onready var ceiling_avoid_cast = $CeilingAvoidCast

const SPEED = 6.0
const CREEP_SPEED = 3.0
const RUN_SPEED = 10.0
const JUMP_VELOCITY = 1.5
const FOOT_HEIGHT = 0.3
var foot_cast_ratio = 0.1
const CAST_WALKING = -1.75
const CAST_JUMPING = -1.15
var LANDING_FRICTION = 20.0 # TODO: get this from ground material
var MAX_FLOOR_ANGLE = 0.3

var walking = false
var running = false
var creeping = false

var input_dir = Vector2.ZERO
var flat_vel = Vector2.ZERO
var flat_dir = Vector2.ZERO
var after_landing_vel = Vector2.ZERO # TODO: add some gun/camera offset based on this
var prev_pos = Vector3.ZERO
var clamber_strength = 0.0

var walk_intersect_query = PhysicsShapeQueryParameters3D.new()

func _ready() -> void:
	foot_cast_ratio = FOOT_HEIGHT / (-jump_recovery_cast.target_position.y)

func on_floor():
	return (floor_cast_center.is_colliding() and (Vector3.UP.angle_to(floor_cast_center.get_collision_normal())) < MAX_FLOOR_ANGLE) \
		or (jump_recovery_cast.is_colliding() and (Vector3.UP.angle_to(jump_recovery_cast.get_collision_normal(0))) < MAX_FLOOR_ANGLE)

func to_floor_fraction():
	var center = 0.0
	if floor_cast_center.is_colliding():
		center = (floor_cast_center.global_position - floor_cast_center.get_collision_point()).length() / floor_cast_center.target_position.length()
	return max(jump_recovery_cast.get_closest_collision_unsafe_fraction(), center)

func get_floor_material():
	if floor_cast_center.is_colliding():
		return floor_cast_center.get_collider()
	elif jump_recovery_cast.is_colliding():
		return jump_recovery_cast.get_collider(0)
	return null

func try_enter_air_state():
	if jump_shape.disabled: # quick check if we are already in the state
		walk_shape.disabled = true
		jump_shape.disabled = false
		floor_cast_center.target_position.y = CAST_JUMPING
		jump_recovery_cast.target_position.y = CAST_JUMPING
		foot_cast_ratio = FOOT_HEIGHT / (-jump_recovery_cast.target_position.y)

func will_walk_shape_collide():
	walk_intersect_query.shape = walk_shape.shape
	walk_intersect_query.collision_mask = collision_mask
	walk_intersect_query.transform = walk_shape.global_transform
	var result = get_world_3d().direct_space_state.intersect_shape(walk_intersect_query, 1)
	return result.size() > 0

func trigger_clamber(clamb):
	gun.trigger_clamber(clamb)
	if clamb > clamber_strength:
		clamber_strength = clamb

func stick_to_ground(delta):
	if on_floor():
		var largest_fraction = to_floor_fraction()
		
		var y_move
		if !walk_shape.disabled:
			y_move = ((1.0 - largest_fraction) * -jump_recovery_cast.target_position.y) - FOOT_HEIGHT
		else:
			y_move = ((1.0 - largest_fraction) * -jump_recovery_cast.target_position.y)
		
		if ceiling_avoid_cast.is_colliding(): # This avoids us dipping down when under a sloped ceiling
			y_move -= min(y_move, ceiling_avoid_cast.get_closest_collision_safe_fraction()) # length is one so this is fine
		
		translate_object_local(Vector3.UP * y_move)
		trigger_clamber(max(1.0 - (largest_fraction + foot_cast_ratio), abs(velocity.y * 0.05)))
		camera.translate_object_local(Vector3.DOWN * y_move)
		
		if walk_shape.disabled:
			after_landing_vel.x = (global_position.x - prev_pos.x) / delta
			after_landing_vel.y = (global_position.z - prev_pos.z) / delta
		walk_shape.disabled = false
		jump_shape.disabled = true
		floor_cast_center.target_position.y = CAST_WALKING
		jump_recovery_cast.target_position.y = CAST_WALKING
		foot_cast_ratio = FOOT_HEIGHT / (-jump_recovery_cast.target_position.y)
		velocity.y = -0.01

func _physics_process(delta: float) -> void:
	var floor_mat = get_floor_material()
	if floor_mat != null:
		MAX_FLOOR_ANGLE = floor_mat.floor_angle
		LANDING_FRICTION = floor_mat.landing_friction
	
	stick_to_ground(delta)
	
	clamber_strength = move_toward(clamber_strength, 0.0, 1.5 * delta)
	
	if walk_shape.disabled or not on_floor():
		velocity += get_gravity() * delta
		try_enter_air_state()
	else:
		velocity.y = -0.01
	
	if Input.is_action_just_pressed("Jump") and on_floor():
		velocity.y = JUMP_VELOCITY
		try_enter_air_state()
	
	input_dir = Input.get_vector("Left", "Right", "Forward", "Back")
	var direction = (Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, camera.rotation.y)).normalized()
	flat_dir.x = direction.x
	flat_dir.y = direction.z
	
	flat_vel.x = velocity.x
	flat_vel.y = velocity.z
	
	running = Input.is_action_pressed("Run")
	creeping = Input.is_action_pressed("Creep")
	walking = direction and on_floor()
	
	var flat_vel_target = flat_dir
	
	if on_floor():
		after_landing_vel = after_landing_vel.move_toward(Vector2.ZERO, LANDING_FRICTION * delta)
		
		if direction:
			if creeping:
				flat_vel_target = flat_vel_target * CREEP_SPEED
			elif running:
				flat_vel_target = flat_vel_target * RUN_SPEED
			else:
				flat_vel_target = flat_vel_target * SPEED
		else:
			flat_vel_target = flat_vel_target * 0
			
		flat_vel_target = flat_vel_target.normalized() * max(0.05, flat_vel_target.length() - (clamber_strength * SPEED * 3.0))
		flat_vel = flat_vel.move_toward(flat_vel_target, (flat_vel - flat_vel_target).length() * 30.0 * delta)
		if after_landing_vel.length_squared() < 0.001:
			flat_vel += after_landing_vel
		else:
			var f = flat_vel.project(after_landing_vel)
			flat_vel -= f
			if f.length_squared() < after_landing_vel.length_squared():
				f = after_landing_vel
			flat_vel += f
	else:
		flat_vel += flat_dir * 4.0 * delta
		if flat_vel.length() > SPEED or not flat_vel:
			flat_vel = flat_vel.move_toward(Vector2.ZERO, 4.0 * delta)
	
	velocity.x = flat_vel.x
	velocity.z = flat_vel.y
	
	prev_pos = global_position
	move_and_slide()
