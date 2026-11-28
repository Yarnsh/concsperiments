extends PhysicalBoneSimulator3D

signal bullet_hit(source)

var dolling = false

func _ready() -> void:
	for c in get_children():
		c.bullet_hit.connect(hit_by_bullet)

func ragdoll():
	dolling = true
	influence = 0.2
	for c in get_children():
		c.collision_layer = 0b00000000_00000000_00000000_00000100
	physical_bones_start_simulation()

func hit_by_bullet(source):
	bullet_hit.emit(source)

func get_all_colliders():
	var result = []
	for c in get_children():
		result.append(c)
	return result

func _process(delta: float) -> void:
	influence = move_toward(influence, 1.0, delta)
