extends Control

@onready var outline = $InteractOutline
@onready var label = $Label

@export var interactable : Node3D

const point_mult = [
	Vector3.BACK,
	Vector3.RIGHT,
	Vector3.UP,
	Vector3(1,1,0),
	Vector3(1,0,1),
	Vector3(0,1,1),
	Vector3.ONE
]

func interact(body):
	if interactable != null and visible:
		interactable.interact(body)

func set_interactable(i):
	if interactable == i:
		return
	if interactable != null:
		interactable.deleting.disconnect(interactable_deleted)
	if i != null:
		i.deleting.connect(interactable_deleted)
	interactable = i

func interactable_deleted():
	interactable.deleting.disconnect(interactable_deleted)
	interactable = null

func _process(delta: float) -> void:
	if interactable != null:
		modulate = interactable.color
		label.text = interactable.text
		
		var aabb = interactable.mesh.get_aabb()
		
		if get_viewport().get_camera_3d().is_position_behind(interactable.mesh.to_global(aabb.position)):
			hide()
			return
		var p0 = get_viewport().get_camera_3d().unproject_position(interactable.mesh.to_global(aabb.position))
		var r = Rect2(p0, Vector2.ZERO)
		
		for mp in point_mult:
			if get_viewport().get_camera_3d().is_position_behind(interactable.mesh.to_global(aabb.position + (aabb.size * mp))):
				hide()
				return
			p0 = get_viewport().get_camera_3d().unproject_position(interactable.mesh.to_global(aabb.position + (aabb.size * mp)))
			r = r.expand(p0)
		
		outline.position = r.position
		outline.size = r.size
		label.position = r.position + (r.size * Vector2.DOWN)
		show()
	else:
		hide()
