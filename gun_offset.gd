extends Node3D

@onready var character = $"../.."
@onready var offsets_parent = $Offset
var offsets = []

@onready var clamber_offset = $Offset/ClamberOffset
@onready var recoil_offset = $Offset/RecoilOffset
@onready var gun_final = $Offset/GunFinal

@onready var muzzle_flash_anim = $Offset/GunFinal/gun/Flash/AnimationPlayer
@onready var heat_haze_effect = $Offset/GunFinal/gun/HeatHaze

var last_cam_move = Vector2.ZERO
var cam_move_offset = Vector2.ZERO
var cam_move_sensitivity = 3.0
var cam_move_recovery = 0.1

var gun_heat = 0.0

func _ready() -> void:
	for c in offsets_parent.get_children():
		if "Offset" in c.name:
			offsets.append(c)

func set_camera_movement(cam_move):
	last_cam_move = cam_move * cam_move_sensitivity

func trigger_clamber(clamb_amount):
	clamber_offset.trigger_clamber(clamb_amount)

func _process(delta: float) -> void:
	var t = Vector3.ZERO
	var r = Vector3.ZERO
	
	# camera movement offset
	cam_move_offset = cam_move_offset.move_toward(last_cam_move, (cam_move_offset - last_cam_move).length() * cam_move_recovery * delta * 60.0)
	cam_move_offset = cam_move_offset.limit_length(50.0)
	r.y = deg_to_rad(-cam_move_offset.x)
	r.x = deg_to_rad(-cam_move_offset.y)
	
	# Additive offsets
	for o in offsets:
		t += o.position * o.transform_amplitude
		r += o.rotation * o.rotation_amplitude
	
	# Apply
	gun_final.position = t
	gun_final.rotation = r
	
	# heat haze visual
	heat_haze_effect.gun_heat = gun_heat
	gun_heat = move_toward(gun_heat, 0.0, 0.05 * delta)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Fire"):
		muzzle_flash_anim.play("flash")
		recoil_offset.shot_fired()
		gun_heat += 0.05
