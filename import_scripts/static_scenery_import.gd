@tool
extends EditorScenePostImport

func _post_import(scene):
	iterate(scene, scene)
	return scene

func iterate(node, scene):
	if node != null:
		if node is MeshInstance3D:
			var mat = node.get_active_material(0)
			if mat is BaseMaterial3D and !node.name.contains("-nm"):
				var new_mat = ShaderMaterial.new()
				new_mat.shader = load("res://shaders/scenery.gdshader")
				new_mat.set_shader_parameter("texture_albedo", mat.albedo_texture)
				
				node.set_surface_override_material(0, new_mat)
			if !node.name.contains("-nc"):
				node.create_trimesh_collision()
		elif node is Light3D:
			node.light_cull_mask = 0b11111111_11111111_11111111_11111110
			node.shadow_enabled = true
			
			var flare = load("res://light_flare.tscn").instantiate() as MeshInstance3D
			node.add_child(flare)
			flare.set_owner(scene)
			flare.position = Vector3.ZERO
			flare.name += "-nm-nc"
			flare.get_active_material(0).set_shader_parameter("albedo", node.light_color)
			flare.get_active_material(0).set_shader_parameter("thing_size", node.light_energy * 0.1)
			
			print(flare.get_active_material(0).get_shader_parameter("thing_size"))
		
		for child in node.get_children():
			iterate(child, scene)
