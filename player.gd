extends Node3D

@onready var body = $CharacterBody3D

func _physics_process(delta: float) -> void:
	body.input.copy_inputs()
