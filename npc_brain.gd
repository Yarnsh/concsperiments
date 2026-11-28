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

@export var calm_brain : Node
@export var searching_brain : Node
@export var aggressive_brain : Node
@export var panic_brain : Node

var barks = {
	"enemy_found": load("res://sfx/voices/target_spotted.wav"),
	"enemy_lost": load("res://sfx/voices/target_lost.wav"),
	"enemy_chase": load("res://sfx/voices/chase.wav"),
	"pain": load("res://sfx/voices/ah.wav"),
	"friendly_fire": load("res://sfx/voices/friendly_fire.wav"),
	"search": load("res://sfx/voices/what_was_that.wav"),
	"follow_noise": load("res://sfx/voices/follow_noise.wav"),
	"confused": load("res://sfx/voices/confused.wav"),
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

func damage_reaction(info):
	match state:
		CALM:
			calm_brain.damage_reaction(info)
		SEARCHING:
			searching_brain.damage_reaction(info)
		AGGRESSIVE:
			aggressive_brain.damage_reaction(info)
		PANIC:
			panic_brain.damage_reaction(info)

func noise_reaction(info):
	var source = info.get("source")
	if source == npc.body:
		return
	match state:
		CALM:
			calm_brain.noise_reaction(info)
		SEARCHING:
			searching_brain.noise_reaction(info)
		AGGRESSIVE:
			aggressive_brain.noise_reaction(info)
		PANIC:
			panic_brain.noise_reaction(info)

func path_next_node():
	if path != null:
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

func plan_done(plan):
	match state:
		CALM:
			calm_brain.plan_done(plan)
		SEARCHING:
			searching_brain.plan_done(plan)
		AGGRESSIVE:
			aggressive_brain.plan_done(plan)
		PANIC:
			panic_brain.plan_done(plan)

func _physics_process(delta: float) -> void:
	match state:
		CALM:
			calm_brain.process()
		SEARCHING:
			searching_brain.process()
		AGGRESSIVE:
			aggressive_brain.process()
		PANIC:
			panic_brain.process()

func _sees_target(age):
	return npc.target_visibility_check and npc.target_visibility_change_age > age
func _not_sees_target(age):
	return !npc.target_visibility_check and npc.target_visibility_change_age > age
