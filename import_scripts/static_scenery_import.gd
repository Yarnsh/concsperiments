@tool
extends EditorScenePostImport

func _post_import(scene):
	iterate(scene, scene)
	return scene

func iterate(node, scene):
	if node != null:
		var children = node.get_children()
		
		if node is MeshInstance3D:
			var spl = Splerger.new()
			var new_meshs = spl.split_by_surface(node, node.get_parent())
			print(new_meshs)
			if new_meshs.size() > 1:
				node.queue_free()
			
			for nnode in new_meshs:
				if nnode != node:
					scene.add_child(nnode)
					nnode.owner = scene
				
				var mat = nnode.get_active_material(0)
				if mat is BaseMaterial3D and !nnode.name.contains("-nm"):
					var new_mat = ShaderMaterial.new()
					new_mat.shader = load("res://shaders/scenery.gdshader")
					new_mat.set_shader_parameter("texture_albedo", mat.albedo_texture)
					
					nnode.set_surface_override_material(0, new_mat)
				if !nnode.name.contains("-nc"):
					nnode.create_trimesh_collision()
					nnode.get_child(0).set_script(load("res://scripts/environment/collider_material.gd"))
			return # if we deleted this node no point looking at the children
		elif node is Light3D:
			node.light_cull_mask = 0b11111111_11111111_11111111_11111110
			node.shadow_enabled = true
			
			var flare = load("res://light_flare.tscn").instantiate() as MeshInstance3D
			node.add_child(flare)
			flare.set_owner(scene)
			flare.position = Vector3.ZERO
			flare.name += "-nm-nc"
			flare.get_active_material(0).set_shader_parameter("albedo", node.light_color)
			flare.get_active_material(0).set_shader_parameter("thing_size", node.light_energy * 0.02)
		
		for child in children:
			iterate(child, scene)
