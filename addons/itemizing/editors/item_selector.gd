@tool
extends PopupPanel

signal on_item_selected(item:ItemData)

@export var item_list:ItemList
@export var submit_btn:Button
@export var search_input:LineEdit

var row_dict:Dictionary = {}


func _enter_tree() -> void:
	var options:ItemizingOptions = preload("res://addons/itemizing/options.tres")
	get_resources(options.item_resource_path)
	item_list.item_activated.connect(on_selected)
	populate_list()
	search_input.text_changed.connect(populate_list)
	submit_btn.pressed.connect(on_submit_pressed)

func on_submit_pressed():
	var selected = item_list.get_selected_items()
	if selected.size() > 0: on_selected(selected[0])

func on_selected(index:int):
	var name = item_list.get_item_text(index)
	on_item_selected.emit(row_dict[name])
	queue_free()


func populate_list(filter:String = ''):
	item_list.clear()
	for key in row_dict.keys():
		if not filter == '' and not filter.to_lower() in key.to_lower(): continue
		item_list.add_item(key)


func get_resources(folder:String):
	print('Searching : ', folder)
	var dir = DirAccess.open(folder)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				get_resources(str(folder, '/', file_name))
			else:
				var res = ResourceLoader.load(str(folder, '/', file_name))
				if res is ItemData:
					print('Found item - ', res.name)
					#add_item_row(res)
					row_dict[res.name] = res
			file_name = dir.get_next()