extends ItemData

@export var heal_amount:int

func on_use(source_inventory:Inventory) -> bool :
	var parent = source_inventory.get_parent()
	if parent is ItemExamplePlayer :
		parent.adjust_health(heal_amount)
		return true
	else :
		return false