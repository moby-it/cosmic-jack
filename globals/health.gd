extends Node

var health = 3

signal enemy_passed
signal reset

func _ready() -> void:
	reset.connect(func(): health = 3)
