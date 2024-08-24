@tool
extends EditorProperty
const TextureEditor = preload("texture_editor.gd")
var editor:TextureEditor = preload("texture_editor.tscn").instantiate()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	editor.texture_changed.connect(_on_texture_changed)
	add_child(editor)
	restore_select.call_deferred()


func _on_texture_changed(texture: Texture2D) -> void:
	var object := get_edited_object()
	var pname := get_edited_property()
	if not (object and pname): return
	var _material := object.get(pname) as StandardMaterial3D
	if not _material:
		_material = StandardMaterial3D.new()
	if _material.albedo_texture == texture:
		return
	_material.albedo_texture = texture
	_material.uv1_triplanar = true
	_material.uv1_world_triplanar = true
	emit_changed(pname, _material)

var regex: RegEx = (func() -> RegEx:
	var _regex = RegEx.new()
	_regex.compile(r'^.*\/(?<color>.*)\/(?<texture>.*?)$')
	return _regex
).call()
	

func restore_select(select_default_if_unset: bool = false) -> void:
	var object := get_edited_object()
	var pname := get_edited_property()
	if not (object and pname): return editor.clear_select()
	var _material := object.get(pname) as StandardMaterial3D
	if not _material:
		editor.select_default() if select_default_if_unset else editor.clear_select()
		return
	if not _material.albedo_texture: return editor.clear_select()
	var result := regex.search(_material.albedo_texture.resource_path)
	if not result: return editor.clear_select()
	var selected_color = result.get_string("color")
	var selected_texture = result.get_string("texture")
	editor.select(selected_color, selected_texture)

func _update_property() -> void:
	restore_select()
