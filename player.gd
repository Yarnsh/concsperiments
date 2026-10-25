extends Node3D

@onready var body = $CharacterBody3D
@onready var cam = $CharacterBody3D/CameraRotator
@onready var model = $CharacterBody3D/Model

func _ready() -> void:
	model.visible = false
	Globals.player_body = body

func _physics_process(delta: float) -> void:
	body.input.copy_inputs()
