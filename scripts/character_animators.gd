extends Node3D

@onready var lower_animator = $LowerBody/AnimationPlayer
@onready var lower_skeleton = $LowerBody/Armature/Skeleton3D
@onready var upper_animator = $UpperBody/AnimationPlayer
@onready var upper_skeleton = $UpperBody/Armature/Skeleton3D
var upper_target_mix = 0.0
@export var upper_mix_blend_time = 0.2 

func _ready() -> void:
	var parent_skel = get_parent()
	parent_skel.mix_skeletons.append(lower_skeleton)
	parent_skel.mix_skeletons.append(upper_skeleton)

func play_upper_body(anim):
	upper_target_mix = 1.0
	upper_animator.play(anim)
func play_lower_body(anim):
	lower_animator.play(anim)

func stop_upper_body():
	upper_target_mix = 0.0
	#upper_animator.stop()
func stop_lower_body():
	lower_animator.stop()

func _process(delta: float) -> void:
	upper_skeleton.mix = move_toward(upper_skeleton.mix, upper_target_mix, delta / upper_mix_blend_time)
