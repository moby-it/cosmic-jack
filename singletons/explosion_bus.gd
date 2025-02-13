extends Node

# Dictionary[convoy_id][enemy_killed_no]
var enemies_exploded = {}

signal exploded

func _ready() -> void:
	exploded.connect(add_enemy_exploded)
	
func add_enemy_exploded(_fruit, enemies_killed: Array[Node2D]):
	for enemy in enemies_killed:
		enemies_exploded[enemy.convoy_id] += 1
