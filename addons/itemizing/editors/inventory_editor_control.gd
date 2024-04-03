@tool
extends PanelContainer

signal size_changed(new:int)
signal slot_changed(slot_id:int, new_amount:int, new_item:ItemData)

@export var load_container:HBoxContainer
@export var random_container:HBoxContainer
@export var size_input:SpinBox
@export var slot_container:VBoxContainer

var slot_control_template = preload("res://addons/itemizing/editors/slot_control.tscn")

var resource_picker:EditorResourcePicker
var loot_table_picker:EditorResourcePicker
var parent_inv:Inventory

func _enter_tree() -> void:
	resource_picker = EditorResourcePicker.new()
	load_container.add_child(resource_picker)
	resource_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	resource_picker.base_type = "InventoryData"

	loot_table_picker = EditorResourcePicker.new()
	random_container.add_child(loot_table_picker)
	loot_table_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	loot_table_picker.base_type = "LootRoll"

	#size_input.text_changed.connect(on_size_changed)
	size_input.value_changed.connect(on_size_submitted)
	#size_input.get_line_edit().editable = false

func on_size_submitted(new:float):
	size_changed.emit(int(new))

func update_data(inv:Inventory):
	await get_tree().process_frame
	print('Updating data')
	parent_inv = inv
	size_input.value = inv.inventory_data.slots.size()
	#size_input.get_line_edit().text = str(inv.size)
	for child in slot_container.get_children():
		child.free()

	for i in inv.inventory_data.slots.size():
		var display = slot_control_template.instantiate()
		slot_container.add_child(display)
		display.display_data(inv.inventory_data.slots[i], i)
		display.slot_changed.connect(on_slot_updated)

func on_slot_updated(slot_id:int, new_amount:int, item:ItemData):
	slot_changed.emit(slot_id, new_amount, item)