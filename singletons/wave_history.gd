extends Node

signal level_change

var history = []

func _ready() -> void:
	level_change.connect(pop_wave)

func add_wave(index: int, hp: int):
	print("Adding wave: index: %s, hp: %s" % [index,hp])
	history.push_back({ "index": index, "hp": hp})

func pop_wave(idx: int, hp: int):
	while idx + 1 < len(history):
		history.pop_back()
