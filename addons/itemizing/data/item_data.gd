extends Resource
class_name ItemData

@export var name: String = ""
@export_multiline var description: String = ""
@export var max_stack:int = 99
@export var sprite: Texture2D
@export var mesh: Mesh


## Called when the item is double clicked in a slot. Override this to implement item effects. Returning true will consume the item from the source inventory.
func on_use(source_inventory:Inventory) -> bool:
	return false