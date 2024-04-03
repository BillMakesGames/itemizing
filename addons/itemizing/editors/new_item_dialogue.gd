@tool
extends Window

signal resource_created()

@export var plugin_options:ItemizingOptions
@export var name_input:LineEdit
@export var description_input:TextEdit
@export var stack_input:SpinBox
@export var save_path_input:LineEdit
@export var save_path_button:Button
@export var script_base_picker:OptionButton

@export var ok_button:Button 
@export var cancel_button:Button

@export var save_popup:FileDialog

@export var display_container:HBoxContainer
var display_input:EditorResourcePicker

@export var mesh_container:HBoxContainer
var mesh_input:EditorResourcePicker

@export var extra_property_container:VBoxContainer
@export var varient_editor:PackedScene

var new_item:ItemData = ItemData.new()

var save_path_set:bool = false
var item_types:Dictionary

func _enter_tree() -> void:
	if display_input: return
	save_path_input.text = plugin_options.item_resource_path
	save_popup.current_path = str(plugin_options.item_resource_path, "/item", '.tres')
	name_input.text_changed.connect(on_name_changed)
	save_path_button.pressed.connect(open_save_popup)
	save_popup.file_selected.connect(on_save_path_set)
	cancel_button.pressed.connect(cancel_pressed)
	ok_button.pressed.connect(create_resource)
	display_input = EditorResourcePicker.new()
	display_container.add_child(display_input)
	display_input.base_type = "Texture2D"
	display_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mesh_input = EditorResourcePicker.new()
	mesh_container.add_child(mesh_input)
	mesh_input.base_type = "Mesh"
	mesh_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#Fill out base picker options
	script_base_picker.clear()
	script_base_picker.add_item('<Default>')
	script_base_picker.add_separator("")
	get_item_types(plugin_options.item_resource_path)
	script_base_picker.item_selected.connect(on_base_selected)


func on_base_selected(index:int):
	if index == 0:
		set_new_base("res://addons/itemizing/data/item_data.gd")
	else:
		set_new_base(item_types[script_base_picker.get_item_text(index)])

func open_save_popup():
	save_popup.show()

func on_name_changed(new:String):
	if save_path_set: return
	var new_path = str(plugin_options.item_resource_path, "/", name_input.text.to_snake_case(), '.tres')
	save_path_input.text = new_path
	save_popup.current_path = new_path

func set_new_base(path:String):
	var script:Resource = load(path).new()
	if script is ItemData:
		print('Is item data!')
		new_item = script
		for child in extra_property_container.get_children():
			child.queue_free()
		var params = get_base_script_params(script)
		for param in params:
			var editor = varient_editor.instantiate()
			extra_property_container.add_child(editor)
			editor.set_param(param["name"], param["type"])
			editor.value_changed.connect(base_param_changed)
	else :
		print('Is NOT item data!')

func base_param_changed(param_name:String, new):
	print(param_name.to_pascal_case(), ' changed to : ', new)
	new_item[param_name] = new

func on_save_path_set(path:String):
	save_path_input.text = path
	save_path_set = true

func cancel_pressed():
	queue_free()

func create_resource():
	if save_path_input.text == '': return
	var data:ItemData = new_item
	data.name = name_input.text
	data.description = description_input.text
	data.max_stack = stack_input.value
	data.sprite = display_input.edited_resource
	data.mesh = mesh_input.edited_resource
	print('Attempting to save new resource...')
	ResourceSaver.save(data, save_path_input.text)
	resource_created.emit()
	queue_free()


func get_base_script_params(data:ItemData) -> Array:
	var base_props = ['description', 'max_stack', 'sprite', 'name', 'mesh']
	var res_script = data.get_script()
	var props = res_script.get_script_property_list()
	var list:Array = []
	for p in props:
		if p.usage == 4102 and not base_props.has(p.name):
			list.push_back(p)
	return list

func get_item_types(folder:String):
	var dir = DirAccess.open(folder)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				get_item_types(str(folder, '/', file_name))
			elif ".gd" in file_name:
				var res:Resource = load(str(folder, '/', file_name)).new()
				if res is ItemData:
					#print('Found item type: ', file_name)
					item_types[file_name] = str(folder, '/', file_name)
					script_base_picker.add_item(file_name)
			file_name = dir.get_next()
