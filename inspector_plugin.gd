@tool
extends EditorInspectorPlugin


func _can_handle(object: Object) -> bool:
	return object is CSGPrimitive3D


func _parse_begin(object: Object) -> void:
	add_property_editor("material", preload("prototype_texture_editor.gd").new(), false, "Material")
