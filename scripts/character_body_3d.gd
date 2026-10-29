extends CharacterBody3D

signal damage_taken(source)

var camera
var gun
var model

@onready var walk_shape = $WalkShape
@onready var jump_shape = $JumpShape
@onready var jump_recovery_cast = $JumpRecoveryCast
@onready var floor_cast_center = $FloorCastCenter

@onready var sfx_foot = $SFXFoot
@onready var sfx_land = $SFXLand
@onready var sfx_slide = $SFXSlide
var sfx_slide_target_volume = 0.0

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

var input = Globals.Inputs.new()
var look_target = Vector3.ZERO
var aim_target = null
var dead = false
var health = 3
var team = null
var loudness = 0.0

var floor_mat = null
var walking = false
var running = false
var creeping = false

var look_angle = 0.0
var aim_angle = 0.0
var input_dir = Vector2.ZERO
var flat_vel = Vector2.ZERO
var flat_dir = Vector2.ZERO
var after_landing_vel = Vector2.ZERO # TODO: add some gun/camera offset based on this
var prev_pos = Vector3.ZERO
var clamber_strength = 0.0

var walk_intersect_query = PhysicsShapeQueryParameters3D.new()

func _ready() -> void:
	camera = get_node_or_null("CameraRotator")
	gun = get_node_or_null("CameraRotator/Gun")
	model = get_node_or_null("Model")
	
	foot_cast_ratio = FOOT_HEIGHT / (-jump_recovery_cast.target_position.y)
	look_target = global_position - global_basis.z
	
	if model != null:
		model.hit_by_bullet.connect(got_shot)
	
	Globals.actors.append(self)

func got_shot(source):
	if health > 0:
		print("OW")
		damage_taken.emit(source)
		health -= 1
		if health <= 0:
			dead = true
			if model != null:
				model.die()

func on_floor():
	return (floor_cast_center.is_colliding() and (Vector3.UP.angle_to(floor_cast_center.get_collision_normal())) < MAX_FLOOR_ANGLE) \
		or (jump_recovery_cast.is_colliding() and (Vector3.UP.angle_to(jump_recovery_cast.get_collision_normal(0))) < MAX_FLOOR_ANGLE)
func touching_floor():
	return floor_cast_center.is_colliding() or jump_recovery_cast.is_colliding()

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
	if gun != null: # TODO: detach this better
		gun.trigger_clamber(clamb)
	if clamb > clamber_strength:
		clamber_strength = clamb

func stick_to_ground(delta):
	if on_floor():
		sfx_slide_target_volume = 0.0
		sfx_slide.set_volume_linear(move_toward(sfx_slide.get_volume_linear(), sfx_slide_target_volume, delta * 2.0))
		
		var largest_fraction = to_floor_fraction()
		
		var y_move
		if !walk_shape.disabled:
			y_move = ((1.0 - largest_fraction) * -jump_recovery_cast.target_position.y) - FOOT_HEIGHT
		else:
			y_move = ((1.0 - largest_fraction) * -jump_recovery_cast.target_position.y)
		
		translate_object_local(Vector3.UP * y_move)
		trigger_clamber(max(1.0 - (largest_fraction + foot_cast_ratio), abs(velocity.y * 0.05)))
		if camera != null: # TODO: detach this better
			camera.global_position.y -= y_move
		
		if walk_shape.disabled:
			sfx_land.set_volume_linear(clamp(-(global_position.y - prev_pos.y) * 0.02 / delta, 0.0, 1.0))
			sfx_land.play()
			after_landing_vel.x = (global_position.x - prev_pos.x) / delta
			after_landing_vel.y = (global_position.z - prev_pos.z) / delta
		walk_shape.disabled = false
		jump_shape.disabled = true
		floor_cast_center.target_position.y = CAST_WALKING
		jump_recovery_cast.target_position.y = CAST_WALKING
		foot_cast_ratio = FOOT_HEIGHT / (-jump_recovery_cast.target_position.y)
		velocity.y = -0.01
	elif touching_floor():
		sfx_slide_target_volume = clamp(((global_position - prev_pos) / delta).length() * 0.04, 0.0, 1.0)
		sfx_slide.set_volume_linear(move_toward(sfx_slide.get_volume_linear(), sfx_slide_target_volume, delta * 1.0))
	else:
		sfx_slide_target_volume = 0.0
		sfx_slide.set_volume_linear(move_toward(sfx_slide.get_volume_linear(), sfx_slide_target_volume, delta * 2.0))

func flat(vec3 : Vector3) -> Vector2:
	return Vector2(vec3.x, vec3.z)

func update_look_angle():
	if camera != null:
		look_angle = camera.rotation.y
		aim_angle = camera.rotation.y
	else:
		look_angle = -((flat(Vector3.FORWARD)).angle_to(flat(look_target) - flat(global_position)))
		if aim_target != null:
			aim_angle = -((flat(Vector3.FORWARD)).angle_to(flat(aim_target) - flat(global_position)))
		else:
			aim_angle = look_angle

func set_floor_noise(def):
	if sfx_foot.stream != def.footstep_sfx:
		sfx_foot.stream = def.footstep_sfx
		sfx_land.stream = def.footstep_sfx
	if sfx_slide.stream != def.slide_sfx:
		sfx_slide.stream = def.slide_sfx
		sfx_slide.play()

func _physics_process(delta: float) -> void:
	loudness = move_toward(loudness, 0.0, delta * 20.0)
	update_look_angle()
	floor_mat = get_floor_material()
	if floor_mat != null:
		MAX_FLOOR_ANGLE = floor_mat.floor_angle
		LANDING_FRICTION = floor_mat.landing_friction
		set_floor_noise(floor_mat)
	
	stick_to_ground(delta)
	
	clamber_strength = move_toward(clamber_strength, 0.0, 1.5 * delta)
	
	if walk_shape.disabled or not on_floor():
		velocity += get_gravity() * delta
		try_enter_air_state()
	else:
		velocity.y = -0.01
	
	if !dead:
		if input.is_action_just_pressed("Jump") and on_floor():
			velocity.y = JUMP_VELOCITY
			try_enter_air_state()
		
		input_dir = input.get_vector("Left", "Right", "Forward", "Back")
		var direction = (Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, look_angle))
		flat_dir.x = direction.x
		flat_dir.y = direction.z
		if flat_dir.length() > 1.0:
			flat_dir = flat_dir.normalized()
		
		flat_vel.x = velocity.x
		flat_vel.y = velocity.z
		
		running = input.is_action_pressed("Run")
		creeping = input.is_action_pressed("Creep")
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
	else:
		velocity.x = 0.0
		velocity.z = 0.0
	
	prev_pos = global_position
	move_and_slide()
