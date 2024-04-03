extends Node
class_name Inventory
## Adds inventory support to it's parent, and provides functions for interacting with it.


## Fired when the contents of the inventory changes.
signal on_updated()
## Fired when an item is added to the inventory.
signal on_item_added(item:ItemData, amount:int)

## The data resource for the inventory contents
@export var inventory_data:InventoryData = InventoryData.new()
## The number of slots contained in the inventory, contents will be truncated if changed to a smaller value.
var size:int:
	set(value):
		change_size(value)
	get:
		return inventory_data.slots.size()

func _ready():
	if not inventory_data.slots[0]:
		size = size
	for i in size:
		inventory_data.slots[i].slot_id = i

##Change the size of the inventory, contents will be truncated if changed to a smaller value.
func change_size(new_size):
	size = new_size
	#print('Setting inventory size to ', size)
	inventory_data.slots.resize(size)
	for i in inventory_data.slots.size():
		if not inventory_data.slots[i]:
			inventory_data.slots[i] = SlotData.new()
			inventory_data.slots[i].slot_id = i

##Adds an item to the inventory, in the first available slot.
func add_item(item:ItemData, amount:int) -> int:
	#print('Adding ', amount, ' x ', item.name)
	var amount_left = amount
	if item.max_stack > 1:
		for slot in inventory_data.slots: #Search for slots to stack into
			if slot.item == item :
				if amount_left + slot.amount <= slot.item.max_stack :
					slot.amount = amount_left + slot.amount;
					on_updated.emit()
					on_item_added.emit(item, amount)
					return 0
				else :
					amount_left = amount_left - (item.max_stack - slot.amount)
					slot.amount = item.max_stack
	for slot in inventory_data.slots: #Search for empty slots
		if not slot.item:
			if amount_left <= item.max_stack:
				slot.item = item
				slot.amount = amount_left
				on_updated.emit()
				on_item_added.emit(item, amount)
				return 0
			else :
				slot.item = item
				slot.amount = item.max_stack
				amount_left = amount_left - item.max_stack
	on_updated.emit()
	on_item_added.emit(item, amount_left)
	return amount_left

## Returns the number of a specific item within the inventory.
func get_item_count(item:ItemData) -> int:
	var count = 0
	for slot in inventory_data.slots:
		if not slot.item == item: continue
		count = count + slot.amount
	return count

## Returns a boolean for if an inventory contains the specified amount of the specified item. Slightly fast then get_item_count.
func has_item(item:ItemData, amount:int = 1) -> bool:
	var found = 0
	for slot in inventory_data.slots:
		if not slot.item == item: continue
		found = found + slot.amount
		if found >= amount: return true
	return false

## Removes a number of a specific item from the inventory. Does not ensure if they are available to remove.
func remove_item(item:ItemData, amount:int = 1) -> void:
	var remaining = amount
	for slot in inventory_data.slots:
		if not slot.item == item: continue
		if slot.amount > remaining:
			slot.amount = slot.amount - remaining
			remaining = 0
			break
		remaining = remaining - slot.amount
		slot.amount = 0
	if remaining < amount: on_updated.emit()

## Remove a number of items from a specific slot.
func remove_from_slot(index:int, amount:int = 1) -> void:
	var slot = inventory_data.slots[index]
	if not slot or not slot.item: return
	slot.amount = slot.amount - 1
	if slot.amount <= 0: clear_slot(index)
	else: on_updated.emit()

## Clears the contents of a specific slot.
func clear_slot(index:int) -> void:
	if not inventory_data.slots[index]: return
	inventory_data.slots[index].item = null
	inventory_data.slots[index].amount = 0
	on_updated.emit()

## Takes a source slot data object, and attempts to add it to the target slot index.[br]
## Stacks items if possible, and will leave the remainder in the source slot data.[br]
## If stacking isn't applicable, the two slot contents will swapped.[br]
##
func transfer_slot(target:int, source_data:SlotData) -> void:
	var slot = inventory_data.slots[target]
	if slot.item: 
		if slot.item == source_data.item: #Try to combine stacks
			if source_data.amount + slot.amount > slot.item.max_stack: #Too full!
				var added = slot.item.max_stack - slot.amount
				source_data.amount = source_data.amount + slot.amount - slot.item.max_stack
				slot.amount = slot.item.max_stack
				on_item_added.emit(source_data.item, added)
			else:
				slot.amount = source_data.amount + slot.amount
				on_item_added.emit(source_data.item, source_data.amount)
		else: #Swap slots
			var item = slot.item
			var amount = slot.amount
			slot.item = source_data.item
			slot.amount = source_data.amount
			source_data.item = item
			source_data.amount = amount
			on_item_added.emit(source_data.amount)
	else: #Moving to an empty slot
		slot.item = source_data.item
		slot.amount = source_data.amount
		source_data.item = null
		source_data.amount = 0

	on_updated.emit()
