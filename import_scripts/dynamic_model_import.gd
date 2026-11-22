@tool
extends EditorScenePostImport

func _post_import(scene):
	iterate(scene, scene)
	return scene

func iterate(node, scene):
	if node != null:
		var children = node.get_children()
		
		if node is MeshInstance3D:
			node.layers = 0b00000000_00000000_00000000_00000011
		
		for child in children:
			iterate(child, scene)
