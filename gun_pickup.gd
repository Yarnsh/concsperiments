extends RigidBody3D

@export var player_prefab : PackedScene
@onready var interactor = $Interactor

func interact(body):
	if body != null:
		if body.camera.pickup_gun(player_prefab):
			interactor.delete()
			queue_free()
