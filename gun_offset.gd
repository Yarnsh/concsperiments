extends Node3D

@onready var character = $"../.."
@onready var walk_offset_anim = $WalkOffset
@onready var walk_offset_real = $Offset/WalkOffset
@onready var strafe_offset = $Offset/WalkOffset/StrafeOffset
@onready var recoil_offset = $Offset/WalkOffset/StrafeOffset/RecoilOffset

@onready var muzzle_flash_anim = $Offset/WalkOffset/StrafeOffset/RecoilOffset/GunFinal/gun/Flash/AnimationPlayer

var last_cam_move = Vector2.ZERO
var cam_move_offset = Vector2.ZERO
var cam_move_sensitivity = 3.0
var cam_move_recovery = 0.1
var strafe_pos = Vector3.ZERO
var recoil = 0.0

func set_camera_movement(cam_move):
	last_cam_move = cam_move * cam_move_sensitivity

func _process(delta: float) -> void:
	rotation = Vector3.ZERO
	
	# camera movement offset
	cam_move_offset = cam_move_offset.move_toward(last_cam_move, (cam_move_offset - last_cam_move).length() * cam_move_recovery * delta * 60.0)
	cam_move_offset = cam_move_offset.limit_length(50.0)
	
	rotate_y(deg_to_rad(-cam_move_offset.x))
	rotate_object_local(Vector3(1,0,0), deg_to_rad(-cam_move_offset.y))
	
	# walk cycle offset
	walk_offset_real.position = walk_offset_anim.position * walk_offset_anim.amplitude
	walk_offset_real.rotation = walk_offset_anim.rotation * walk_offset_anim.amplitude * 2.0
	
	# strafe offset
	strafe_pos.x = character.input_dir.x * 0.1
	strafe_pos.z = character.input_dir.y * 0.1
	strafe_offset.position = strafe_offset.position.move_toward(strafe_pos, (strafe_offset.position - strafe_pos).length() * 10.0 * delta)
	strafe_offset.rotation.z = strafe_offset.position.x * -2.5
	
	# recoil offset
	recoil_offset.position.z = recoil * 0.2
	recoil_offset.position.y = recoil * 0.2
	recoil_offset.rotation.x = recoil * 0.5
	recoil_offset.rotation.y = recoil * -0.1
	recoil = move_toward(recoil, 0.0, ((recoil * 5.0) + 1.0) * delta)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Fire"):
		muzzle_flash_anim.play("flash")
		recoil += 1.0
