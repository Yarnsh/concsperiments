extends Node

@onready var npc = $".."
@export var path : Node3D
@export var hold_ground = false
var path_idx = 0
var path_dir = 1

var state = "CALM"

func _ready() -> void:
	npc.damage_taken.connect(damage_reaction)
	npc.plan_done.connect(plan_done)
	if path != null:
		path.done.connect(path_ready)
		npc.set_target_plan(npc.follow_path, 60)
	npc.speed_input = 0

func path_ready():
	npc.set_path(path.points[0])

func damage_reaction(source):
	if source in Globals.actors:
		npc.attack_target = source
		npc.set_target_plan(npc.fire_at_target, 30)
		npc.speed_input = 1
		state = "AGGRESSIVE"

func plan_done():
	if npc.current_plan == npc.follow_path and path != null:
		path_idx += path_dir
		if path_idx < 0 or path_idx >= len(path.points):
			if path.pingpong:
				path_dir = -path_dir
				path_idx += path_dir * 2
			elif path.loop:
				path_idx = posmod(path_idx, len(path.points))
			else:
				path = null
		if path != null:
			npc.set_path(path.points[path_idx])

func _physics_process(delta: float) -> void:
	if npc.current_plan == npc.fire_at_target:
		if !npc.target_visibility_check and npc.target_visibility_change_age > 60:
			if !hold_ground:
				npc.set_target_plan(npc.pursue_target, 0)
			else:
				npc.set_target_plan(npc.stop, 60)
				state = "SEARCHING"
	elif npc.current_plan == npc.pursue_target:
		if npc.target_visibility_check and npc.target_visibility_change_age > 10:
			npc.set_target_plan(npc.fire_at_target, 20)
		elif !npc.target_visibility_check and npc.target_visibility_change_age > 300:
			state = "SEARCHING"
			if !hold_ground:
				npc.set_target_plan(npc.move_to_random, 0)
			else:
				npc.set_target_plan(npc.stop, 0)
	elif state == "SEARCHING":
		var target = npc.find_visible_target()
		if target != null:
			state = "AGGRESIVE"
			npc.attack_target = target
			npc.set_plan_immediately(npc.stop)
			npc.set_target_plan(npc.fire_at_target, 60)
