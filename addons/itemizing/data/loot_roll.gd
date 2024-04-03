extends Resource
class_name LootRoll

@export var item:ItemData
@export_range(0,1) var chance:float = 1
@export var number_of_rolls:int = 1