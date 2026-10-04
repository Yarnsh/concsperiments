extends Skeleton3D

@export var mix = 1.0
@export var active_bone : StringName
var active_bone_ids = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var active_bone = find_bone(active_bone)
	if active_bone < 0:
		active_bone = 0
	find_active_bone_children(active_bone)

func find_active_bone_children(active_bone):
	for cid in get_bone_children(active_bone):
		find_active_bone_children(cid)
	active_bone_ids.append(active_bone)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
