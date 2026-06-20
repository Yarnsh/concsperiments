extends CharacterBody3D

@onready var camera = $CameraRotator

const SPEED = 6.0
const CREEP_SPEED = 3.0
const RUN_SPEED = 10.0
const JUMP_VELOCITY = 4.5

var walking = false
var running = false
var creeping = false

var input_dir = Vector2.ZERO
var flat_vel = Vector2.ZERO
var flat_dir = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	input_dir = Input.get_vector("Left", "Right", "Forward", "Back")
	var direction = (Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, camera.rotation.y)).normalized()
	flat_dir.x = direction.x
	flat_dir.y = direction.z
	
	flat_vel.x = velocity.x
	flat_vel.y = velocity.z
	
	running = Input.is_action_pressed("Run")
	creeping = Input.is_action_pressed("Creep")
	walking = direction and is_on_floor()
	
	var flat_vel_target = flat_dir
	
	if is_on_floor():
		if direction:
				if creeping:
					flat_vel_target = flat_vel_target * CREEP_SPEED
				elif running:
					flat_vel_target = flat_vel_target * RUN_SPEED
				else:
					flat_vel_target = flat_vel_target * SPEED
		else:
			flat_vel_target = flat_vel_target * 0
		flat_vel = flat_vel.move_toward(flat_vel_target, (flat_vel - flat_vel_target).length() * 30.0 * delta)
	
	velocity.x = flat_vel.x
	velocity.z = flat_vel.y
	
	move_and_slide()
