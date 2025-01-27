extends Node2D

@export var score = 0
@onready var label = $ColorRect/Label

func _ready() -> void:
	label.text += " %s" % str(score)
