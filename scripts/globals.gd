extends Node

var nav = null
var actors = []

var player_body = null

class Inputs:
	var pressed = {}
	var just_pressed = []
	var just_released = []
	
	func is_action_pressed(action):
		return action in pressed
	func is_action_just_pressed(action):
		return action in just_pressed
	func is_action_just_released(action):
		return action in just_released
	func get_vector(l, r, u, d):
		return Vector2(pressed.get(r, 0.0) - pressed.get(l, 0.0), pressed.get(d, 0.0) - pressed.get(u, 0.0))
	
	func tick():
		# controller of the inputs should call this once per frame before updating the inputs
		just_pressed.clear()
		just_released.clear()
	
	func copy_inputs():
		pressed = {}
		just_pressed = []
		just_released = []
		for action in InputMap.get_actions():
			if Input.is_action_pressed(action):
				pressed[action] = Input.get_action_strength(action)
			if Input.is_action_just_pressed(action):
				just_pressed.append(action)
			if Input.is_action_just_released(action):
				just_released.append(action)
	
	func set_input(action, value):
		if value == 0.0:
			if pressed.erase(action):
				just_released.append(action)
		else:
			if action not in pressed:
				just_pressed.append(action)
			pressed[action] = value
	
	func set_2axis(value : Vector2, l, r, u, d):
		if value.x < 0.0:
			set_input(l, abs(value.x))
			set_input(r, 0.0)
		else:
			set_input(r, abs(value.x))
			set_input(l, 0.0)
		if value.y < 0.0:
			set_input(d, abs(value.y))
			set_input(u, 0.0)
		else:
			set_input(u, abs(value.y))
			set_input(d, 0.0)
