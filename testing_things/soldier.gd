extends Node3D

var anims = {
	"death": "pistol_guy/Armature|death",
	"walk": "pistol_guy/Armature|walk",
	"stand": "pistol_guy/Armature|test_move",
	
	"walk_forward": "combat_walks/Armature|walk_forward",
	"walk_back": "combat_walks/Armature|walk_back",
	"walk_right": "combat_walks/Armature|walk_right",
	"walk_left": "combat_walks/Armature|walk_left",
	
	"aim": "combat_walks/Armature|walk_forward"
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
		anim.stop_upper_body()
		anim.play_lower_body(anims["death"])

func _process(delta: float) -> void:
	if !character.dead:
		aim_ik.target = character.aim_target
		
		if character.aim_target != null:
			anim.play_upper_body(anims["aim"], 0.3)
			
			var lat = character.aim_target
			lat.y = global_position.y
			look_at(lat)
			rotate_y(PI) # TODO: make the model face the right way I guess
			if character.walking:
				var angle = global_basis.z.signed_angle_to(Vector3(character.flat_dir.x, 0.0, character.flat_dir.y), Vector3.UP)
				if angle < PI/4 and angle > -PI/4:
					anim.play_lower_body(anims["walk_forward"])
				elif angle > (PI/4) * 3 or angle < -(PI/4) * 3:
					anim.play_lower_body(anims["walk_back"])
				elif angle >= PI/4 and angle <= (PI/4) * 3:
					anim.play_lower_body(anims["walk_left"])
				elif angle <= -PI/4 and angle >= -(PI/4) * 3:
					anim.play_lower_body(anims["walk_right"])
			else:
				anim.play_lower_body(anims["stand"])
		else:
			anim.stop_upper_body()
			if character.walking:
				anim.play_lower_body(anims["walk"])
			else:
				anim.play_lower_body(anims["stand"])
	else:
		aim_ik.target = null
