@tool
extends PanelContainer

signal refresh_list()

@export var content:HBoxContainer
@export var name_edit:LineEdit
@export var description_edit:LineEdit
@export var stack_edit:SpinBox
@export var more_options_button:Button
@export var extra_options:VBoxContainer
@export var custom_props_container:VBoxContainer
@export var delete_button:Button
@export var delete_confirmation:ConfirmationDialog
@export var script_base_picker:OptionButton

var current_item:ItemData
var display_picker:EditorResourcePicker
var mesh_picker:EditorResourcePicker
var extra_shown = false
var item_types:Dictionary

static var plugin_options:ItemizingOptions = preload("res://addons/itemizing/options.tres")
static var varient_editor:PackedScene = preload("res://addons/itemizing/editors/varient_property_editor.tscn")

# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	if display_picker: return
	display_picker = EditorResourcePicker.new()
	content.add_child(display_picker)
	display_picker.base_type = "Texture2D"
	display_picker.custom_minimum_size = Vector2(150,0)
	display_picker.resource_changed.connect(on_display_set)

	mesh_picker = EditorResourcePicker.new()
	content.add_child(mesh_picker)
	mesh_picker.base_type = "Mesh"
	mesh_picker.custom_minimum_size = Vector2(150,0)
	mesh_picker.resource_changed.connect(on_mesh_set)

	name_edit.text_submitted.connect(on_name_set)
	name_edit.focus_exited.connect(on_name_defocus)
	description_edit.text_submitted.connect(on_description_set)
	description_edit.focus_exited.connect(on_description_defocus)
	stack_edit.value_changed.connect(on_stack_set)
	more_options_button.pressed.connect(toggle_extra_options)

	delete_button.pressed.connect(on_delete_pressed)
	delete_confirmation.confirmed.connect(on_delete_confirmed)


func on_delete_pressed():
	delete_confirmation.show()

func on_delete_confirmed():
	var path =current_item.resource_path
	var dir = DirAccess.open("res://")
	dir.remove(path)
	EditorInterface.get_resource_filesystem().scan()
	refresh_list.emit()

func toggle_extra_options():
	extra_shown = not extra_shown
	if extra_shown:
		extra_options.show()
		script_base_picker.clear()
		script_base_picker.add_item('<Default>')
		script_base_picker.add_separator("")
		get_item_types(plugin_options.item_resource_path)
		script_base_picker.item_selected.connect(on_base_selected)
	else:
		extra_options.hide()

func on_base_selected(index:int):
	var path = ''
	if index == 0:
		path = "res://addons/itemizing/data/item_data.gd"
	else:
		path = item_types[script_base_picker.get_item_text(index)]
	#Backup default properties
	var _name = current_item.name
	var _description = current_item.description
	var _max_stack = current_item.max_stack
	var _sprite = current_item.sprite
	var _mesh = current_item.mesh
	#Change base script
	var new_script = ResourceLoader.load(path)
	current_item.set_script(new_script)
	#restore base properties
	current_item.name = _name
	current_item.description = _description
	current_item.max_stack = _max_stack
	current_item.sprite = _sprite
	current_item.mesh = _mesh
	#refresh view
	set_item(current_item)

func on_name_set(new:String):
	current_item.name = new
	current_item.emit_changed()

func on_name_defocus():
	name_edit.text = current_item.name

func on_description_set(new:String):
	print('Set description')
	current_item.description = new
	current_item.emit_changed()

func on_description_defocus():
	description_edit.text = current_item.description

func on_stack_set(new:int):
	current_item.max_stack = new
	current_item.emit_changed()

func on_display_set(new:Texture2D):
	current_item.sprite = new
	current_item.emit_changed()

func on_mesh_set(new:Mesh):
	current_item.mesh = new
	current_item.emit_changed()

func set_item(item:ItemData):
	current_item = item
	if not current_item.changed.is_connected(update_item_properties):
		current_item.changed.connect(update_item_properties)
	update_item_properties()
	var custom_props = get_base_script_params(item)
	for child in custom_props_container.get_children():
		if not child is Label: child.queue_free()
	for prop in custom_props:
		var editor = varient_editor.instantiate()
		custom_props_container.add_child(editor)
		editor.set_param(prop["name"], prop["type"], item[prop["name"]])
		editor.value_changed.connect(on_extra_param_changed)
	#var script:Script = item.get_script()
	#var script_path = script.resource_path
	#var script_name = item_types.find_key(script_path)
	#if script_name:
		#for i in script_base_picker.get
		

func on_extra_param_changed(param_name:String, new):
	print(param_name.to_pascal_case(), ' changed to : ', new)
	current_item[param_name] = new
	current_item.emit_changed()	

func update_item_properties():
	#Set base properties
	name_edit.text = current_item.name
	description_edit.text = current_item.description
	stack_edit.value = current_item.max_stack
	if current_item.sprite: display_picker.edited_resource = current_item.sprite
	if current_item.mesh and mesh_picker: mesh_picker.edited_resource = current_item.mesh


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
	var id = 10
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
					script_base_picker.add_item(file_name, id)
					#print(current_item.get_script().resource_path, " =?= ", item_types[file_name])
					if current_item.get_script().resource_path == item_types[file_name]:
						#print('Found item script')
						script_base_picker.select(script_base_picker.get_item_index(id))
					id += 1
			file_name = dir.get_next()