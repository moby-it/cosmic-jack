extends Node

signal level_change

var level_index = 1
var history = []

func _ready() -> void:
	level_change.connect(pop_wave)

func add_wave(index: int, wave: Wave):
	print("Adding wave to history: index: %s" % [index])
	history.push_back({ "index": index, "wave": wave})

func pop_wave(idx: int, _hp: int):
	while idx + 1 < len(history):
		history.pop_back()
