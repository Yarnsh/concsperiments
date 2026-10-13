extends Node3D

@onready var camera = $SubViewport/Node3D/Camera3D
@export var spin = 1.0
@export var intensity = 1.0

@onready var subviewport = $SubViewport
@onready var fall = $Fall

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_intensity(intensity)
	camera.rotate_y(spin)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate(basis.y.normalized(),spin)

func set_intensity(i):
	intensity = i
	subviewport.size = Vector2i(64, 64) * i
	fall.amount = 2400 * i * i
	fall.process_material.emission_point_count = subviewport.size.x * subviewport.size.y
