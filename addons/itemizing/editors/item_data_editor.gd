extends EditorProperty

var control = preload("res://addons/itemizing/editors/item_data_control.tscn").instantiate()

func _init() -> void:
	add_child(control)
	#set_bottom_editor(control)
	control.item_changed.connect(on_item_changed)


func on_item_changed(new:ItemData):
	get_edited_object()[get_edited_property()] = new

func _update_property() -> void:
	control.update_value(get_edited_object()[get_edited_property()])