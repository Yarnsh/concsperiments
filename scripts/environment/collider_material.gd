extends Node

var material_name = "unknown"

var floor_angle = 0.0
var bullet_hole = null
var hit_vfx = null

func _ready() -> void:
	var ml = get_parent().name.rsplit("_", true, 1)
	if ml.size() > 1:
		material_name = ml[1]
	
	var def = ColliderMaterialDefinitions.defs.get(material_name, {})
	if "floor_angle" in def:
		floor_angle = def["floor_angle"]
	else:
		floor_angle = ColliderMaterialDefinitions.defaults["floor_angle"]
	if "bullet_hole" in def:
		bullet_hole = load(def["bullet_hole"])
	else:
		bullet_hole = load(ColliderMaterialDefinitions.defaults["bullet_hole"])
	if "hit_vfx" in def:
		hit_vfx = load(def["hit_vfx"])
	else:
		hit_vfx = load(ColliderMaterialDefinitions.defaults["hit_vfx"])
