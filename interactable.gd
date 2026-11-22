extends Node3D

signal deleting

@export var to_interact : Node
@export var meshs : Array[MeshInstance3D]
var model : Node3D
@export var text = "Unknown"
@export var color = Color.WHITE

var aabb : AABB

func _ready() -> void:
	Globals.interactables.append(self)
	if len(meshs) > 0:
		aabb = AABB(meshs[0].get_aabb())
		model = meshs[0].get_parent()
	else:
		aabb = AABB(Vector3.ZERO, Vector3.ONE * 0.1)
		model = self
	for m in meshs:
		aabb = aabb.merge(m.get_aabb())

func interact(body):
	if to_interact != null:
		to_interact.interact(body)

func delete():
	Globals.interactables.erase(self)
	deleting.emit()
