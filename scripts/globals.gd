extends Node

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
	func get_vector(l, r, d, u):
		return Vector2(pressed.get(r, 0.0) - pressed.get(l, 0.0), pressed.get(u, 0.0) - pressed.get(d, 0.0))
	
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

# DEBUG STUFF
var player = null
