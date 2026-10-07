extends Skeleton3D

var mix_skeletons : Array[Skeleton3D]
var id_mapping = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for bid in range(get_bone_count()):
		id_mapping.append(mix_skeletons[0].find_bone(get_bone_name(bid)))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for bid in range(get_bone_count()):
		if id_mapping[bid] < 0:
			continue
		var t = Transform3D.IDENTITY
		for s in mix_skeletons:
			t = t.interpolate_with(s.get_bone_pose(id_mapping[bid]), s.mix)
		set_bone_pose(bid, t)
