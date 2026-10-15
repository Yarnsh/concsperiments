extends Node3D

var anims = {
	"death": "pistol_guy/Armature|death",
	"walk": "pistol_guy/Armature|walk",
	"stand": "pistol_guy/Armature|test_move"
}

@onready var character = $".."
@onready var colliders = $Colliders
@onready var anim = $Armature/Skeleton3D/Animators
@onready var aim_ik = $Armature/Skeleton3D/AimIK

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	colliders.bullet_hit.connect(hit_by_bullet)

func hit_by_bullet():
	if !character.dead:
		character.dead = true
		anim.play_lower_body(anims["death"])

func _process(delta: float) -> void:
	if !character.dead:
		aim_ik.target = character.aim_target
		
		if character.walking:
			anim.play_lower_body(anims["walk"])
		else:
			anim.play_lower_body(anims["stand"])
	else:
		aim_ik.target = null
