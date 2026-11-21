extends RigidBody3D

@export var player_prefab : PackedScene
@onready var interactor = $Interactor
@onready var col_sfx = $CollisionSFX
var prev_vel = null

func _ready() -> void:
	body_entered.connect(collided)

func interact(body):
	if body != null:
		if body.camera.pickup_gun(player_prefab):
			interactor.delete()
			queue_free()

func collided(body):
	col_sfx.stream = body.footstep_sfx

func _physics_process(delta: float):
	if prev_vel != null:
		if (prev_vel - linear_velocity).length_squared() > 1.0:
			col_sfx.play()
	prev_vel = linear_velocity
