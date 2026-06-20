extends Node3D

@onready var character = $"../../.."
@onready var anim = $AnimationPlayer
var amplitude = 0.0
var target_amp = 0.0
var speed = 1.0
var target_speed = 1.0
var was_walking = false
var walk_stop_time = -1
const AFTER_WALK_TIME = 500

func _process(delta: float) -> void:
	target_amp = 0.0
	target_speed = 1.0
	if character.walking:
		was_walking = true
		target_speed = 1.5
		target_amp = 0.5
		if character.creeping:
			target_speed = 1.2
			target_amp = 0.2
		elif character.running:
			target_speed = 2.0
			target_amp = 1.0
		if !anim.is_playing():
			anim.play("walk_offset")
	else:
		if was_walking:
			was_walking = false
			walk_stop_time = Time.get_ticks_msec()
	
	if !was_walking and walk_stop_time > 0 and Time.get_ticks_msec() > walk_stop_time + AFTER_WALK_TIME:
		anim.stop()
		walk_stop_time = -1
	
	amplitude = move_toward(amplitude, target_amp, 3.0 * delta)
	speed = move_toward(speed, target_speed, 5.0 * delta)
	anim.speed_scale = speed
