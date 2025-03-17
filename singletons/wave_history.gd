extends Node

signal level_change

var level_index = 1
var history = []
# Store fruit positions for the last failed wave
var last_failed_fruits = []

func _ready() -> void:
	level_change.connect(pop_wave)

func add_wave(index: int, hp: int, wave: Wave):
	print("Adding wave to history: index: %s, hp: %s" % [index, hp])
	history.push_back({ "index": index, "hp": hp, "wave": wave})

func pop_wave(idx: int, _hp: int):
	while idx + 1 < len(history):
		history.pop_back()
		
func save_failed_fruits(fruits_data: Array):
	last_failed_fruits = fruits_data
	
func get_failed_fruits() -> Array:
	return last_failed_fruits
	
func clear_failed_fruits():
	last_failed_fruits.clear()
