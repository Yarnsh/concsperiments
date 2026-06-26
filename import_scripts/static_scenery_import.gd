@tool
extends EditorScenePostImport

func _post_import(scene):
	iterate(scene)
	return scene

func iterate(node):
	if node != null:
		if node is MeshInstance3D:
			var mat = node.get_active_material(0)
			if mat is BaseMaterial3D:
				var new_mat = ShaderMaterial.new()
				new_mat.shader = load("res://shaders/scenery.gdshader")
				new_mat.set_shader_parameter("texture_albedo", mat.albedo_texture)
				
				node.set_surface_override_material(0, new_mat)
			if !node.name.contains("-nc"):
				node.create_trimesh_collision()
		elif node is Light3D:
			node.light_cull_mask = 0b11111111_11111111_11111111_11111110
			node.shadow_enabled = true
		
		for child in node.get_children():
			iterate(child)
