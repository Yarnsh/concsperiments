extends GodotIK

@export var target_influence = 0.0
@export var blend_time = 0.5

func _process(delta: float) -> void:
	influence = move_toward(influence, target_influence, delta / blend_time)
