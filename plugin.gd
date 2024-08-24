@tool
extends EditorPlugin

const InspectorPlugin = preload("inspector_plugin.gd")

var instance: InspectorPlugin

func _enter_tree() -> void:
	print()
	instance = InspectorPlugin.new()
	add_inspector_plugin(instance)


func _exit_tree() -> void:
	remove_inspector_plugin(instance)
