@tool
extends MarginContainer

signal texture_changed(texture: Texture2D)

@onready var colors_button: OptionButton = %ColorsButton
@onready var texture_picker_button: Button = %TexturePickerButton
@onready var textures: ItemList = %Textures
@onready var texture_preview: TextureRect = %TexturePreview

var textures_root := preload("kenney_prototype-textures/Preview.png").resource_path.trim_suffix("/Preview.png")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if EditorInterface.get_edited_scene_root() == self: return
	texture_picker_button.icon = get_theme_icon("GuiDropdown", "EditorIcons")
	colors_button.clear()
	for n in DirAccess.open(textures_root).get_directories():
		colors_button.add_item(n)
	

func _on_colors_button_item_selected(index: int) -> void:
	var selected_items := textures.get_selected_items()
	var selected_texture_idx := 0 if selected_items.is_empty() else selected_items[0]
	textures.clear()
	update_textures(colors_button.get_item_text(index))
	emit_change(colors_button.get_item_text(index), textures.get_item_text(selected_texture_idx))


func _on_texture_picker_button_button_down() -> void:
	var point := texture_picker_button.get_screen_transform() * Vector2(0,texture_picker_button.size.y)
	%PopupPanel.popup(Rect2(point, Vector2(100,100)))


func _on_textures_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	if colors_button.selected == -1: return
	if mouse_button_index != MOUSE_BUTTON_LEFT: return
	emit_change(colors_button.get_item_text(colors_button.selected), textures.get_item_text(index))

func update_textures(color: String) -> void:
	var base_path := textures_root.path_join(color)
	textures.clear()
	for texture in DirAccess.open(base_path).get_files():
		var path := base_path.path_join(texture)
		if not ResourceLoader.exists(path, "Texture2D"): continue
		textures.add_item(texture, ResourceLoader.load(path, "Texture2D"))

func emit_change(color: String, texture: String) -> void:
	var path := textures_root.path_join(color).path_join(texture)
	var tex := ResourceLoader.load(path, "Texture2D")
	texture_preview.texture = tex
	texture_changed.emit(tex)

func select(color: String, texture: String) -> void:
	for i in colors_button.item_count:
		if color != colors_button.get_item_text(i): continue
		colors_button.select(i)
		update_textures(color)
		for j in textures.item_count:
			if texture != textures.get_item_text(j): continue
			textures.select(j)
			emit_change(color, texture)
			return
		return

func select_default() -> void:
	for i in colors_button.item_count:
		var color := colors_button.get_item_text(i)
		if color.is_empty(): continue
		colors_button.select(i)
		update_textures(color)
		if textures.item_count:
			var texture := textures.get_item_text(0)
			textures.select(0)
			emit_change(color, texture)
			return

func clear_select() -> void:
	colors_button.select(-1)
	textures.deselect_all()
	texture_preview.texture = null
