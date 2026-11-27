extends Node

@onready var npc = $"../.."
@onready var brain = $".."

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

func process():
	pass
