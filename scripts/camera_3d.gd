extends Node3D

@onready var body = $".."
@onready var primary_gun = $Gun
@onready var interact_hud = $Interact

@export var gun_offset : Node
@export var secondary_gun : Node

var _mouse_position = Vector2(0.0, 0.0)
var _total_pitch = 0.0
var sensitivity = 0.3

var cam_dist_max = 8.0
var cam_dist_min = 0.25
var cam_distance = 4.0

var start_position = Vector3.ZERO

var spring_strength = 7.0
var up_strength = 17.0

func _ready() -> void:
	start_position = position
	get_parent().input.action_pressed.connect(input_pressed)
	call_deferred("add_gun_exceptions", primary_gun)
	if secondary_gun != null:
		call_deferred("add_gun_exceptions", secondary_gun)

func add_gun_exceptions(gun):
	gun.add_exceptions(body.model.colliders.get_all_colliders())

func _process(delta: float) -> void:
	_update_mouselook()
	_update_interact()
	
	if position.y < start_position.y:
		position = position.move_toward(start_position, (start_position - position).length_squared() * spring_strength * delta)
	else:
		position = position.move_toward(start_position, (start_position - position).length_squared() * up_strength * delta)

func _physics_process(delta: float) -> void:
	if body.input.is_action_pressed("Fire"):
		gun_offset.fire_held()

func _update_mouselook():
	# Only rotates mouse if the mouse is captured
	#if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
	_mouse_position *= sensitivity
	var yaw = _mouse_position.x
	var pitch = _mouse_position.y
	gun_offset.set_camera_movement(_mouse_position)
	_mouse_position = Vector2(0, 0)
	
	# Prevents looking up/down too far
	pitch = clamp(pitch, -80 - _total_pitch, 80 - _total_pitch)
	_total_pitch += pitch

	rotate_y(deg_to_rad(-yaw))
	rotate_object_local(Vector3(1,0,0), deg_to_rad(-pitch))

func _update_interact():
	var closest = null
	var dist = 2.0
	var dot = 0.0
	for i in Globals.interactables:
		var d = global_position.distance_to(i.global_position)
		var do = (i.global_position - global_position).normalized().dot(-global_basis.z)
		if d < dist and do > dot:
			closest = i
			dot = do
	interact_hud.set_interactable(closest)

func pickup_gun(prefab):
	drop_secondary()
	
	var g = prefab.instantiate()
	add_child(g)
	secondary_gun = g
	primary_gun.hide()
	secondary_gun.show()
	gun_offset = secondary_gun
	gun_offset.add_exceptions(body.model.colliders.get_all_colliders())
	secondary_gun.trigger_raise()
	return true

func drop_secondary():
	if secondary_gun != null:
		var drop = secondary_gun.pickup_prefab.instantiate()
		get_owner().add_child(drop)
		drop.global_transform = body.global_transform
		drop.linear_velocity = global_basis.z * -3.0
		secondary_gun.hide()
		secondary_gun.queue_free()
		secondary_gun = null

func switch_gun():
	# not sure if I want gun switching, for now its just a secondary drop
	if secondary_gun != null:
		drop_secondary()
		gun_offset = primary_gun
		primary_gun.show()
		primary_gun.trigger_raise()
	
	return # old switching code
	if gun_offset == primary_gun and secondary_gun != null:
		primary_gun.hide()
		secondary_gun.show()
		gun_offset = secondary_gun
	elif gun_offset == secondary_gun:
		primary_gun.show()
		secondary_gun.hide()
		gun_offset = primary_gun

func input_pressed(action):
	if action == "Fire":
		gun_offset.fire()
	elif action == "Switch_Gun":
		switch_gun()
	elif action == "Interact":
		interact_hud.interact(body)

func _input(event):
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			_mouse_position = event.relative
