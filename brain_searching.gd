extends Node

@onready var npc = $"../.."
@onready var brain = $".."

func damage_reaction(info):
	var source = info.get("source")
	if source != null:
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
	var source = info.get("source")
	if source != null and source.team != npc.team:
		if !brain.hold_ground:
			npc.speed_input = 1
			npc.set_path(source.global_position)
			npc.set_target_plan(npc.follow_path, 30)
			npc.play_bark(brain.barks.get("follow_noise"))
		else:
			npc.body.look_target = source.global_position

func plan_done(plan):
	if plan == npc.follow_path:
		brain.path_next_node()

func process():
	var target = npc.find_visible_target()
	if target != null:
		npc.play_bark(brain.barks.get("enemy_found"))
		brain.state = brain.AGGRESSIVE
		npc.gun_ready = true
		npc.attack_target = target
		npc.set_plan_immediately(npc.stop)
		npc.set_target_plan(npc.fire_at_target, 60, brain.fire_burst_frames)
