extends BoneAttachment3D

@onready var character = $"../.."

@onready var vfx = $gun/Flash/AnimationPlayer
@onready var sfx = $gun/SFX
@onready var hit_ray = $gun/HitRay

@export var spread = 0.08

func _ready() -> void:
	# TODO: pick the bone ID based on the expected bone name, as our skeleton might have a different bone order
	character.input.action_pressed.connect(action_pressed)
	hit_ray.source = character

func add_exceptions(exc):
	for e in exc:
		hit_ray.add_exception(e)

func action_pressed(action):
	if action == "Fire":
		fire()

func fire():
	vfx.play("flash")
	sfx.play()
	
	hit_ray.rotation = Vector3.ZERO
	if character.aim_target != null:
		hit_ray.look_at(character.aim_target)
	hit_ray.rotate(hit_ray.basis.z.normalized(), randf() * 2*PI)
	hit_ray.rotate(hit_ray.basis.x.normalized(), randf() * spread)
	hit_ray.fire()
