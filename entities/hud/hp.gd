extends Node2D

var hp = 3
@onready var hp_label = $HP

func _ready() -> void:
	Health.connect("enemy_passed", reduce_hp)

func reduce_hp():
	hp -= 1
	hp_label.text = str(hp)
