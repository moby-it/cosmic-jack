extends Node

signal level_change

var history = []

func _ready() -> void:
	level_change.connect(pop_wave)

func add_wave(index: int, hp: int, wave: Wave):
	print("Adding wave: index: %s, hp: %s, wave %s" % [index, hp, wave])
	history.push_back({ "index": index, "hp": hp, "wave": wave})

func pop_wave(idx: int, hp: int):
	while idx + 1 < len(history):
		history.pop_back()
