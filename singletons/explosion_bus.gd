extends Node

var enemies_exploded = {}

signal exploded

func _ready() -> void:
	exploded.connect(add_enemy_exploded)
	
func add_enemy_exploded(i, enemies_killed):
	for k in enemies_killed:
		enemies_exploded[k] = null
	
