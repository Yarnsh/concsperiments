extends Node3D

@export var target : Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	target = Globals.player.global_position + (Vector3.UP * 0.1)
	look_at(target, Vector3.UP, true)
