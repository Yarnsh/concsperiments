extends Node3D

@onready var animator = $Armature/Skeleton3D/Animators
@onready var aim_ik = $Armature/Skeleton3D/AimIK

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("DEBUG_0"):
		if aim_ik.target_influence < 0.5:
			aim_ik.target_influence = 1.0
		else:
			aim_ik.target_influence = 0.0
	elif event.is_action_pressed("DEBUG_1"):
		animator.play_upper_body("pistol_guy/Armature|pistol_aim")
	elif event.is_action_pressed("DEBUG_2"):
		animator.stop_upper_body()
