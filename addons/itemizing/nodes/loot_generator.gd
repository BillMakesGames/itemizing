extends Node
class_name LootGenerator

@export var rolls:LootTable

func get_loot() -> Array[ItemData]:
	var result:Array[ItemData] = []
	for roll in rolls.rolls:
		for i in roll.number_of_rolls:
			if randf() < roll.chance:
				result.push_back(roll.item)
	return result
