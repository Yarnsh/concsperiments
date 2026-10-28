extends BoneAttachment3D

@export var bone = "mixamorig_LeftFoot"
@onready var model = $"../../.."
@onready var checker = $RayCast3D
var was_colliding = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bone_idx = get_parent().find_bone(bone)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if checker.is_colliding() and was_colliding == false:
		model.footstep()
	was_colliding = checker.is_colliding()
