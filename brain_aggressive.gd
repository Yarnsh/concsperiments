extends Node

@onready var npc = $"../.."
@onready var brain = $".."

enum {
	FIRING,
	SEARCHING,
}

var state = FIRING

func damage_reaction(source):
	if source in Globals.actors:
		if source.team == npc.team:
			npc.gun_ready = false
			npc.attack_target = null
			npc.set_target_plan(npc.move_to_random, 5, 60)
			brain.state = brain.PANIC
			npc.speed_input = 2
			npc.play_bark(brain.barks.get("friendly_fire"))
		else:
			npc.gun_ready = true
			npc.attack_target = source
			npc.set_target_plan(npc.fire_at_target, 30, brain.fire_burst_frames)
			npc.speed_input = 1
			brain.state = brain.AGGRESSIVE
			npc.play_bark(brain.barks.get("pain"))

func noise_reaction(info):
	pass

func plan_done(plan):
	if plan == npc.follow_path:
		brain.path_next_node()
	
	if brain._not_sees_target(30):
		state = SEARCHING
		if brain.hold_ground:
			npc.set_target_plan(npc.stop, 0)
		else:
			npc.set_plan_immediately(npc.stop)
			npc.set_target_plan(npc.pursue_target, 30)
	else:
		match plan:
			npc.fire_at_target:
				if brain.hold_ground:
					npc.set_target_plan(npc.stop, 0, brain.fire_break_frames)
				else:
					npc.set_target_plan(npc.move_to_random, 0, brain.fire_break_frames)
			npc.stop:
				npc.set_target_plan(npc.fire_at_target, 0, brain.fire_burst_frames)
			npc.move_to_random:
				npc.set_target_plan(npc.fire_at_target, 0, brain.fire_burst_frames)

func process():
	if state == FIRING:
		pass
	elif state == SEARCHING:
		if brain._sees_target(10):
			state = FIRING
			npc.set_target_plan(npc.fire_at_target, 20, brain.fire_burst_frames)
		elif brain._not_sees_target(300):
			brain.state = brain.SEARCHING
			npc.gun_ready = true
			npc.play_bark(brain.barks.get("enemy_lost"))
			npc.attack_target = null
			if !brain.hold_ground:
				npc.set_target_plan(npc.move_to_random, 0)
			else:
				npc.set_target_plan(npc.stop, 0)
