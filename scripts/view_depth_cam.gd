extends Camera3D

@export var follow_cam : Camera3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	near = follow_cam.near
	far = follow_cam.far


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_transform = follow_cam.global_transform
	fov = follow_cam.fov
