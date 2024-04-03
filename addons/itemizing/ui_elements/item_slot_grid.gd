@tool
extends GridContainer
class_name ItemSlotGrid

@export var linked_inventory:Inventory:
	set(value):
		if Engine.is_editor_hint() and linked_inventory: linked_inventory.inventory_data.changed.disconnect(on_inventory_changed)
		linked_inventory = value
		attach_to_inventory(value)
		if Engine.is_editor_hint() and linked_inventory: linked_inventory.inventory_data.changed.connect(on_inventory_changed)
		if not Engine.is_editor_hint(): value.on_updated.connect(on_inventory_updated)

static var slot_template:PackedScene = preload("res://addons/itemizing/ui_elements/item_slot_control.tscn")

func _ready() -> void:
	if linked_inventory:
		attach_to_inventory(linked_inventory)

func on_inventory_changed():
	attach_to_inventory(linked_inventory)

func attach_to_inventory(inv:Inventory):
	#print('Attaching grid to inventory')
	for child in get_children():
		child.queue_free()
	if not inv: return
	#print("displaying ", inv.inventory_data.slots.size())
	for slot in inv.inventory_data.slots:
		#print("Adding slot control")
		var new_slot = slot_template.instantiate()
		add_child(new_slot)
		if not Engine.is_editor_hint(): 
			new_slot.owning_data = slot
			new_slot.owning_inventory = inv

func on_inventory_updated():
	#print('Inventory updated')
	for child in get_children():
		child.redraw()
