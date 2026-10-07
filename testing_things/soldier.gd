extends Node3D

@onready var colliders = $Colliders
@onready var anim = $Armature/Skeleton3D/Animators

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	colliders.bullet_hit.connect(hit_by_bullet)

func hit_by_bullet():
	anim.play_lower_body("pistol_guy/Armature|death")
