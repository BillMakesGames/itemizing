extends Resource
class_name SlotData

@export var item: ItemData
@export var amount: int = 1: set = set_quantity
var slot_id:int


func set_quantity(value:int) -> void:
	amount = value
	if item and item.max_stack < amount:
		amount = item.max_stack
		push_error("Attempted to set quantity of %s beyond max stack count. Setting to max." % item.name)