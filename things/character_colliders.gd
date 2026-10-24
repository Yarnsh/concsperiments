extends Node3D

signal bullet_hit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for c in get_children():
		var rb = c.get_child(0)
		rb.bullet_hit.connect(hit_by_bullet)

func hit_by_bullet():
	bullet_hit.emit()

func get_all_colliders():
	var result = []
	for c in get_children():
		result.append(c.get_child(0))
	return result
