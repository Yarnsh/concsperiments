@tool
extends EditorScenePostImport

func _post_import(scene):
	
	var colliders_prefab = load("res://things/character_colliders.tscn")
	var colliders = colliders_prefab.instantiate()
	scene.add_child(colliders)
	colliders.set_owner(scene)
	
	var animation_player = scene.find_child("AnimationPlayer")
	animation_player.queue_free()
	
	var skeleton = scene.find_child("Skeleton3D")
	
	for b in colliders.get_children():
		var bid = skeleton.find_bone(b.bone_name)
		if bid >= 0:
			b.bone_idx = bid
		else:
			b.queue_free()
	
	for c in skeleton.get_children():
		if c is MeshInstance3D:
			c.layers = 0b00000000_00000000_00000000_00000010
			var mat = c.get_active_material(0)
			if mat is BaseMaterial3D and !c.name.contains("-nm"):
				var new_mat = ShaderMaterial.new()
				new_mat.shader = load("res://shaders/scenery.gdshader")
				new_mat.set_shader_parameter("texture_albedo", mat.albedo_texture)
				
				c.set_surface_override_material(0, new_mat)
	
	var animators_prefab = load("res://things/character_animators.tscn")
	var animators = animators_prefab.instantiate()
	skeleton.add_child(animators)
	animators.set_owner(scene)
	var aim_ik_prefab = load("res://things/aim_ik.tscn")
	var aim_ik = aim_ik_prefab.instantiate()
	skeleton.add_child(aim_ik)
	aim_ik.set_owner(scene)
	skeleton.set_script(load("res://scripts/mixed_skeleton.gd"))
	
	return scene
