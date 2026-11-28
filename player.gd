extends Node3D

@onready var body = $CharacterBody3D
@onready var cam = $CharacterBody3D/CameraRotator
@onready var model = $CharacterBody3D/Model

func _ready() -> void:
	model.visible = false
	model.disable_model_footsteps()
	Globals.player_body = body
	cam.gun_offset.add_exceptions(model.colliders.get_all_colliders())

func _physics_process(delta: float) -> void:
	body.input.copy_inputs()
	body.aim_target = body.global_position - cam.global_basis.z
