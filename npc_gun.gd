extends BoneAttachment3D

@onready var character = $"../.."
const target_name = "mixamorig_RightHand"

@onready var palm = $PalmOffset
var gun = null

@export var spread = 0.08

func _ready() -> void:
	bone_name = target_name
	
	character.input.action_pressed.connect(action_pressed)
	gun = get_child(0).get_child(0)
	if gun != null:
		gun.enable_npc_mode(character)
		call_deferred("add_exceptions")

func add_exceptions():
	gun.add_exceptions(character.model.colliders.get_all_colliders())

func pickup_gun(prefab):
	var g = prefab.instantiate()
	palm.add_child(g)
	g.enable_npc_mode()
	gun = g
	add_exceptions()
	return true

func drop_gun():
	if gun != null:
		var drop = gun.pickup_prefab.instantiate()
		get_owner().add_child(drop)
		drop.global_transform = character.global_transform
		drop.linear_velocity = global_basis.z * -3.0
		gun.hide()
		gun.queue_free()
		gun = null

func action_pressed(action):
	if action == "Fire":
		fire()

func fire():
	gun.shooter.rotation = Vector3.ZERO
	if character.aim_target != null:
		gun.shooter.look_at(character.aim_target)
	gun.shooter.rotate(gun.shooter.basis.z.normalized(), randf() * 2*PI)
	gun.shooter.rotate(gun.shooter.basis.x.normalized(), randf() * spread)
	gun.fire()
