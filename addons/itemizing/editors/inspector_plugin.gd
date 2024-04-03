extends EditorInspectorPlugin

var inventory_editor = preload("res://addons/itemizing/editors/inventory_editor.gd")
var item_data_editor = preload("res://addons/itemizing/editors/item_data_editor.gd")

func _can_handle(object: Object) -> bool:
	return true

func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	if name == 'inventory_data' and object is Inventory:
		add_property_editor(name, inventory_editor.new()) 
		return true
	elif type == 24 and hint_type == 17 and hint_string == 'ItemData':
		add_property_editor(name, item_data_editor.new())
		return true
	else:
		return false