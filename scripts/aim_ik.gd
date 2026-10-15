extends GodotIK

@onready var aimer_node = $Hips/Node3D

@export var target_influence = 0.0
@export var blend_time = 0.5
var target = null

func _process(delta: float) -> void:
	if target != null:
		target_influence = 1.0
	else:
		target_influence = 0.0
	influence = move_toward(influence, target_influence, delta / blend_time)
	aimer_node.target = target
