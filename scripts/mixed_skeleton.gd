extends Skeleton3D

var mix_skeletons : Array[Skeleton3D]
var id_mapping = []
var bone_bumps = {}
@onready var aim_ik = $AimIK

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
			if id_mapping[bid] in s.active_bone_ids:
				t = t.interpolate_with(s.get_bone_pose(id_mapping[bid]), s.mix)
		set_bone_pose(bid, t)
	
	for bid in bone_bumps.keys():
		set_bone_pose(bid, get_bone_pose(bid).rotated_local(bone_bumps[bid][0], bone_bumps[bid][1]))
		bone_bumps[bid][1] = max(0.0, bone_bumps[bid][1] - 3.0 * delta)

func bump_bone(bid, angle):
	bone_bumps[bid] = [Vector3.RIGHT.rotated(Vector3.FORWARD, randf() * 2*PI), angle]
	# the AimIK bump is a really hacky way to prevent it from overwriting the bone bumps,
	# but it looks fine for damage so keep it simple
	aim_ik.bump(angle)
