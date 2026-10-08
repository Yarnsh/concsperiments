extends Node3D

@onready var body = $CharacterBody3D

func _physics_process(delta: float) -> void:
	body.input.tick()
	
	# test movement
	body.look_target = Vector3(5, 0.6, -17)
	#body.input.set_input("Left", 0.1)
	body.input.set_2axis(Vector2.DOWN * 0.2, "Left", "Right", "Forward", "Back")
