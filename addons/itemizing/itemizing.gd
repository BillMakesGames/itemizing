@tool
extends EditorPlugin

const db_editor_template = preload("res://addons/itemizing/editors/database_editor.tscn")
var inspect_plugin
var db_editor

func _enter_tree() -> void:
	inspect_plugin = preload("res://addons/itemizing/editors/inspector_plugin.gd").new()
	add_inspector_plugin(inspect_plugin)
	#DB Editor
	db_editor = db_editor_template.instantiate()
	EditorInterface.get_editor_main_screen().add_child(db_editor)
	_make_visible(false)
	#Custom Node Types
	add_custom_type('Inventory', 'Node', preload("res://addons/itemizing/nodes/inventory_component.gd"), preload("res://addons/itemizing/icons/inventory.png"))
	add_custom_type('LootGenerator', 'Node', preload("res://addons/itemizing/nodes/loot_generator.gd"), preload("res://addons/itemizing/icons/inventory.png"))


func _exit_tree() -> void:
	remove_inspector_plugin(inspect_plugin)
	remove_custom_type('Inventory')
	if db_editor:
		db_editor.queue_free()


func _has_main_screen():
	return true


func _make_visible(visible):
	if db_editor:
		db_editor.visible = visible


func _get_plugin_name():
	return "Itemizing"


func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")