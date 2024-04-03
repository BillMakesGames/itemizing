@tool
extends PanelContainer

@export var plugin_options:ItemizingOptions
@export var file_picker:FileDialog
@export var change_folder_button:Button
@export var refresh_button:Button
@export var item_container:VBoxContainer
@export var item_row_template:PackedScene
@export var directory_label:Label
@export var new_item:Button
@export var search_bar:LineEdit

var current_folder:String
var new_panel_template = preload("res://addons/itemizing/editors/new_item_dialogue.tscn")
var row_dict:Dictionary = {}

func _enter_tree() -> void:
	change_folder_button.pressed.connect(change_directory)
	refresh_button.pressed.connect(refresh_view)
	file_picker.dir_selected.connect(refresh_view)
	new_item.pressed.connect(new_button_clicked)
	#Wait a frame to load resources to make sure the tree is full initialized.
	await get_tree().process_frame
	refresh_view(plugin_options.item_resource_path)
	search_bar.text_changed.connect(search_changed)


func new_button_clicked():
	var popup = new_panel_template.instantiate()
	add_child(popup)
	popup.resource_created.connect(refresh_view)


func refresh_view(folder:String = ''):
	if folder == '': folder = plugin_options.item_resource_path
	#Save the new directory
	if not folder == plugin_options.item_resource_path: plugin_options.item_resource_path = folder
	directory_label.text = folder
	#Clear out the item list to repopulate.
	for child in item_container.get_children():
		child.queue_free()
	row_dict.clear()
	var base_container = VBoxContainer.new()
	item_container.add_child(base_container)
	get_resources(folder, '', base_container)


func change_directory():
	file_picker.show()


func search_changed(value:String):
	value = value.to_lower()
	if value == '':
		for row in row_dict.values():
			row.show()
	else:
		for key in row_dict.keys():
			if value in key.to_lower():
				row_dict[key].show()
			else :
				row_dict[key].hide()


func get_resources(folder:String, section:String = '', base_container:VBoxContainer = null):
	var rows = []
	var dir = DirAccess.open(folder)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				#print("Found directory: " + file_name + "---------")
				#add_section_header(file_name)
				get_resources(str(folder, '/', file_name), file_name)
			else:
				#print("Found resource: " + file_name)
				var res = ResourceLoader.load(str(folder, '/', file_name))
				if res is ItemData:
					#add_item_row(res)
					rows.push_back(res)
			file_name = dir.get_next()
	if rows.size() > 0:
		var container
		if not section == '':
			container = add_section_header(section)
		else :
			container = base_container
		for row in rows:
			add_item_row(row, container)




func add_item_row(item:ItemData, container:VBoxContainer):
	var row = item_row_template.instantiate()
	container.add_child(row)
	row.set_item(item)
	row_dict[item.name] = row
	row.refresh_list.connect(refresh_view)


func add_section_header(section_name:String) -> VBoxContainer:
	var title = Label.new()
	title.text = section_name.to_pascal_case()
	title.add_theme_font_size_override('font_size', 20)
	item_container.add_child(HSeparator.new())
	item_container.add_child(title)
	item_container.add_child(HSeparator.new())
	var section_container = VBoxContainer.new()
	item_container.add_child(section_container)
	return section_container