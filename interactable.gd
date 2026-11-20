extends Node3D

signal deleting

@export var to_interact : Node
@export var mesh : MeshInstance3D
@export var text = "Unknown"
@export var color = Color.WHITE

func _ready() -> void:
	Globals.interactables.append(self)

func interact(body):
	if to_interact != null:
		to_interact.interact(body)

func delete():
	Globals.interactables.erase(self)
	deleting.emit()
