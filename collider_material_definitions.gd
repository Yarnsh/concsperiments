extends Node

const defaults = {
	"floor_angle": deg_to_rad(40),
	"landing_friction": 20.0,
	"bullet_hole": "res://vfx/concrete_bullet_hole_decal.tscn",
	"hit_vfx": "res://vfx/concrete_hit_effect.tscn"
}

const defs = {
	"conc": {
		"floor_angle": deg_to_rad(40),
		"landing_friction": 20.0,
		"bullet_hole": "res://vfx/concrete_bullet_hole_decal.tscn",
		"hit_vfx": "res://vfx/concrete_hit_effect.tscn"
	},
	"wood": {
		"floor_angle": deg_to_rad(15),
		"bullet_hole": "res://vfx/wood_bullet_hole_decal.tscn"
	},
	"shiny": {
		"floor_angle": deg_to_rad(5),
		"landing_friction": 1.0
	}
}
