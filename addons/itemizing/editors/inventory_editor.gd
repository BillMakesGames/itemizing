extends EditorProperty

var property_control = preload("res://addons/itemizing/editors/inventory_editor_control.tscn").instantiate()
var current_value:InventoryData


# Called when the node enters the scene tree for the first time.
func _init() -> void:
	add_child(property_control)
	set_bottom_editor(property_control)
	property_control.size_changed.connect(on_size_changed)
	property_control.slot_changed.connect(on_slot_changed)
	property_pinned.emit("inventory_data", true)
	

func on_size_changed(new:int):
	var inv:Inventory = get_edited_object()
	inv.inventory_data.slots.resize(new)
	for i in inv.inventory_data.slots.size():
		if not inv.inventory_data.slots[i]:
			inv.inventory_data.slots[i] = SlotData.new()
	property_control.update_data(inv)
	inv.inventory_data.emit_changed()


func on_slot_changed(slot_id:int, new_amount:int, new_item:ItemData):
	var inv:Inventory = get_edited_object()
	inv.inventory_data.slots[slot_id].amount = new_amount
	inv.inventory_data.slots[slot_id].item = new_item
	property_control.update_data(inv)
	inv.inventory_data.emit_changed()


func _update_property() -> void:
	var inv = get_edited_object()
	if not inv.inventory_data: 
		inv.inventory_data = InventoryData.new()
		inv.size = 8
	property_control.update_data(inv)