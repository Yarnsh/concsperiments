extends Node3D

@export var pickup_prefab_path : StringName
var pickup_prefab = null

@onready var character = $"../.."
@onready var offsets_parent = $Offset
var offsets = []

@onready var raise_offset = $Offset/RaiseOffset
@onready var clamber_offset = $Offset/ClamberOffset
@onready var recoil_offset = $Offset/RecoilOffsetLate
@onready var gun_final = $Offset/GunFinal

@onready var muzzle_flash_anim = $Offset/GunFinal/gun/Flash/AnimationPlayer
@onready var heat_haze_effect = $Offset/GunFinal/gun/HeatHaze
@onready var shot_sfx = $ShotSFX
@onready var fire_noise = $FireNoise

@onready var shooter = $Offset/GunFinal/gun/HitRay

var last_cam_move = Vector2.ZERO
var cam_move_offset = Vector2.ZERO
var cam_move_sensitivity = 3.0
var cam_move_recovery = 0.1

var gun_heat = 0.0

@export var auto = false
@export var shot_delay = 0
var shot_time = 0

var npc = false

func _ready() -> void:
	pickup_prefab = load(pickup_prefab_path)
	shooter.source = character
	for c in offsets_parent.get_children():
		if "Offset" in c.name:
			offsets.append(c)

func enable_npc_mode(body):
	character = body
	shooter.source = character
	npc = true
	offsets_parent.transform = Transform3D.IDENTITY
	for o in offsets:
		o.set_process(false)

func add_exceptions(exc):
	for e in exc:
		shooter.add_exception(e)

func set_camera_movement(cam_move):
	last_cam_move = cam_move * cam_move_sensitivity

func trigger_clamber(clamb_amount):
	clamber_offset.trigger_clamber(clamb_amount)

func trigger_raise():
	raise_offset.start_raise()

func _process(delta: float) -> void:
	if !npc:
		var t = Vector3.ZERO
		var r = Vector3.ZERO
		
		# camera movement offset
		cam_move_offset = cam_move_offset.move_toward(last_cam_move, (cam_move_offset - last_cam_move).length() * cam_move_recovery * delta * 60.0)
		cam_move_offset = cam_move_offset.limit_length(50.0)
		r.y = deg_to_rad(-cam_move_offset.x)
		r.x = deg_to_rad(-cam_move_offset.y)
		
		# Additive offsets
		for o in offsets:
			if "Late" not in o.name:
				t += o.position * o.transform_amplitude
				r += o.rotation * o.rotation_amplitude
		
		# Apply
		gun_final.position = t
		gun_final.rotation = r
		
		# Late offsets
		for o in offsets:
			if "Late" in o.name:
				gun_final.translate_object_local(o.position * o.transform_amplitude)
				gun_final.rotate_object_local(Vector3.UP, o.rotation.y * o.rotation_amplitude)
				gun_final.rotate_object_local(Vector3.RIGHT, o.rotation.x * o.rotation_amplitude)
				gun_final.rotate_object_local(Vector3.FORWARD, o.rotation.z * o.rotation_amplitude)
	
	# heat haze visual
	heat_haze_effect.gun_heat = gun_heat
	gun_heat = move_toward(gun_heat, 0.0, 0.05 * delta)

func emit_noise():
	for b in fire_noise.get_overlapping_bodies():
		b.noise_alert(character)

func fire_held():
	if auto:
		fire()

func fire():
	if Time.get_ticks_msec() > shot_time + shot_delay:
		shot_time = Time.get_ticks_msec()
		shooter.fire()
		muzzle_flash_anim.play("flash")
		shot_sfx.play()
		recoil_offset.shot_fired()
		gun_heat += 0.05
		emit_noise()
