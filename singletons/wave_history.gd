extends Node

signal level_change

var history = []

func _ready() -> void:
	level_change.connect(pop_wave)

func add_wave(index: int, hp: int, ammo: Dictionary):
	print("Adding wave: index: %s, hp: %s, ammo: %s" % [index,hp, ammo])
	history.push_back({ "index": index, "hp": hp, "ammo": ammo.duplicate(true)})

func pop_wave(idx: int, hp: int):
	if len(history) == 1:
		Fruits.ammo = history[0].ammo.duplicate(true)
		return
	while idx + 1 < len(history):
		history.pop_back()
	var entry = history[len(history) -1]
	Fruits.ammo = entry.ammo.duplicate(true)
