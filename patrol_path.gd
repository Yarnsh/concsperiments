extends Node3D

signal done

@export var loop = false
@export var pingpong = false

var points = []

func _ready() -> void:
	await NavigationServer3D.map_changed
	await get_tree().create_timer(0.1).timeout
	setup()
	done.emit()

func setup():
	for c in get_children():
		points.append(NavigationServer3D.map_get_closest_point(Globals.nav.get_navigation_map(), c.global_position))
