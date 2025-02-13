extends Resource
class_name Ammo

@export var apples = 0
@export var watermelons = 0
@export var cherries = 0

func get_fruits() -> Dictionary:
	return {
		"apple": apples,
		"watermelon": watermelons,
		"cherry": cherries
	}
