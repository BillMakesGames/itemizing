@tool
extends HBoxContainer

signal item_changed(new:ItemData)

var picker:PackedScene = preload("res://addons/itemizing/editors/item_selector.tscn")
var text:LineEdit
var button:Button

func _enter_tree() -> void:
	button = $Button
	text = $LineEdit
	$Button.pressed.connect(show_picker)


func show_picker():
	var popup = picker.instantiate()
	add_child(popup)
	popup.on_item_selected.connect(on_item_selected)

func on_item_selected(newItem:ItemData):
	text.text = newItem.name
	item_changed.emit(newItem)

func update_value(new:ItemData):
	if new:
		text.text = new.name
	else :
		text.text = '<Empty>'