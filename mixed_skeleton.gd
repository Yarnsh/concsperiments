extends Skeleton3D

var mix_skeletons : Array[Skeleton3D]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for bid in range(get_bone_count()):
		var t = Transform3D.IDENTITY
		for s in mix_skeletons:
			if bid in s.active_bone_ids:
				t = t.interpolate_with(s.get_bone_pose(bid), s.mix)
		set_bone_pose(bid, t)
