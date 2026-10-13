extends Node3D

@onready var body = $CharacterBody3D
@onready var cam = $CharacterBody3D/CameraRotator

func _physics_process(delta: float) -> void:
	body.input.copy_inputs()
	if body.floor_mat != null:
		cam.set_footstep_noise(body.floor_mat.footstep_sfx)
