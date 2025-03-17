extends Node

signal health_depleted
signal level_completed
signal wave_completed
signal fruit_placed
signal wave_resolving
signal exploded

var enemies_exploded = {}

func _ready() -> void:
	exploded.connect(add_enemy_exploded)
	
func add_enemy_exploded(_fruit, enemies_killed: Array[Node2D]):
	for enemy in enemies_killed:
		enemies_exploded[enemy.convoy_id] += 1
