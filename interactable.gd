extends Node3D

@export var mesh : MeshInstance3D
@export var text = "Unknown"
@export var color = Color.WHITE

func _ready() -> void:
	Globals.interactables.append(self)

func interact(body):
	print(body, " interacted with this")
