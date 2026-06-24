extends GPUParticles3D

@onready var camera = $SubViewport/Node3D/Camera3D
@export var spin = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera.rotate_y(spin)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate_y(spin)
