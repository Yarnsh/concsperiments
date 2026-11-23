extends Node

@onready var npc = $".."
var path_idx = 0
var path_dir = 1

enum {
	CALM,
	SEARCHING,
	AGGRESSIVE,
	PANIC,
}

var barks = {
	"enemy_found": load("res://sfx/voices/target_spotted.wav"),
	"enemy_lost": load("res://sfx/voices/target_lost.wav"),
	"enemy_chase": load("res://sfx/voices/chase.wav"),
	"pain": load("res://sfx/voices/ah.wav"),
	"friendly_fire": load("res://sfx/voices/friendly_fire.wav"),
	"search": load("res://sfx/voices/what_was_that.wav"),
	"follow_noise": load("res://sfx/voices/follow_noise.wav"),
}

var state = CALM

@export var path : Node3D
@export var hold_ground = false
@export var fire_burst_frames = 60
@export var fire_break_frames = 120

func _ready() -> void:
	npc.damage_taken.connect(damage_reaction)
	npc.noise_heard.connect(noise_reaction)
	npc.plan_done.connect(plan_done)
	if path != null:
		path.done.connect(path_ready)
		npc.set_target_plan(npc.follow_path, 60)
	npc.speed_input = 0

func path_ready():
	npc.set_path(path.points[0])

func damage_reaction(source):
	if source in Globals.actors:
		if source.team == npc.team:
			npc.gun_ready = false
			npc.attack_target = null
			npc.set_target_plan(npc.move_to_random, 5, 60)
			state = PANIC
			npc.speed_input = 2
			npc.play_bark(barks.get("friendly_fire"))
		else:
			npc.gun_ready = true
			npc.attack_target = source
			npc.set_target_plan(npc.fire_at_target, 30, fire_burst_frames)
			npc.speed_input = 1
			state = AGGRESSIVE
			npc.play_bark(barks.get("pain"))

func noise_reaction(source):
	if source == npc.body:
		return
	match state:
		CALM:
			npc.gun_ready = true
			state = SEARCHING
			npc.play_bark(barks.get("search"))
			npc.speed_input = 0
		SEARCHING:
			if source != null and source.team != npc.team:
				if !hold_ground:
					npc.speed_input = 1
					npc.set_path(source.global_position)
					npc.set_target_plan(npc.follow_path, 30)
					npc.play_bark(barks.get("follow_noise"))
				else:
					npc.body.look_target = source.global_position #TODO: make a proper "look over here" method

func plan_done(plan):
	print(plan, ", ", state)
	if plan == npc.follow_path and path != null:
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
	match state:
		CALM:
			npc.set_plan_immediately(npc.stop)
		PANIC:
			npc.gun_ready = true
			state = SEARCHING
			npc.speed_input = 0
			npc.set_plan_immediately(npc.stop)
			npc.set_target_plan(npc.move_to_random, 60)
		AGGRESSIVE:
			if _not_sees_target(30):
				if hold_ground:
					npc.set_target_plan(npc.stop, 0)
				else:
					npc.set_plan_immediately(npc.stop)
					npc.set_target_plan(npc.pursue_target, 30)
			else:
				match plan:
					npc.fire_at_target:
						if hold_ground:
							npc.set_target_plan(npc.stop, 0, fire_break_frames)
						else:
							npc.set_target_plan(npc.move_to_random, 0, fire_break_frames)
					npc.stop:
						npc.set_target_plan(npc.fire_at_target, 0, fire_burst_frames)
					npc.move_to_random:
						npc.set_target_plan(npc.fire_at_target, 0, fire_burst_frames)

func _physics_process(delta: float) -> void:
	match state:
		CALM:
			pass
		SEARCHING:
			var target = npc.find_visible_target()
			if target != null:
				npc.play_bark(barks.get("enemy_found"))
				state = AGGRESSIVE
				npc.gun_ready = true
				npc.attack_target = target
				npc.set_plan_immediately(npc.stop)
				npc.set_target_plan(npc.fire_at_target, 60, fire_burst_frames)
		AGGRESSIVE:
			if npc.current_plan == npc.fire_at_target:
				pass
			elif npc.current_plan == npc.pursue_target:
				if _sees_target(10):
					npc.set_target_plan(npc.fire_at_target, 20, fire_burst_frames)
				elif _not_sees_target(300):
					state = SEARCHING
					npc.gun_ready = true
					npc.play_bark(barks.get("enemy_lost"))
					npc.attack_target = null
					if !hold_ground:
						npc.set_target_plan(npc.move_to_random, 0)
					else:
						npc.set_target_plan(npc.stop, 0)
		PANIC:
			pass
	
	return
	# Old logic
	if npc.current_plan == npc.fire_at_target:
		if !npc.target_visibility_check and npc.target_visibility_change_age > 60:
			if !hold_ground:
				npc.set_target_plan(npc.pursue_target, 0)
				npc.play_bark(barks.get("enemy_chase"))
			else:
				npc.set_target_plan(npc.stop, 60)
				npc.attack_target = null
				npc.play_bark(barks.get("enemy_lost"))
				state = SEARCHING
	elif npc.current_plan == npc.pursue_target:
		if npc.target_visibility_check and npc.target_visibility_change_age > 10:
			npc.set_target_plan(npc.fire_at_target, 20)
		elif !npc.target_visibility_check and npc.target_visibility_change_age > 300:
			state = SEARCHING
			npc.gun_ready = true
			npc.play_bark(barks.get("enemy_lost"))
			npc.attack_target = null
			if !hold_ground:
				npc.set_target_plan(npc.move_to_random, 0)
			else:
				npc.set_target_plan(npc.stop, 0)
	elif state == SEARCHING:
		var target = npc.find_visible_target()
		if target != null:
			npc.play_bark(barks.get("enemy_found"))
			state = AGGRESSIVE
			npc.gun_ready = true
			npc.attack_target = target
			npc.set_plan_immediately(npc.stop)
			npc.set_target_plan(npc.fire_at_target, 60)

func _sees_target(age):
	return npc.target_visibility_check and npc.target_visibility_change_age > age
func _not_sees_target(age):
	return !npc.target_visibility_check and npc.target_visibility_change_age > age
