extends Node3D

signal bullet_hit(source)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for c in get_children():
		var skel = c.get_skeleton()
		c.bone_idx = skel.find_bone(c.bone_name)
		
		var rb = c.get_child(0)
		rb.bullet_hit.connect(hit_by_bullet)

func hit_by_bullet(info):
	bullet_hit.emit(info)

func get_all_colliders():
	var result = []
	for c in get_children():
		result.append(c.get_child(0))
	return result

func disable():
	for c in get_children():
		c.get_child(0).collision_layer = 0
