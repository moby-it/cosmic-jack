extends Node

signal level_completed
signal wave_completed
signal fruit_placed
signal exploded

var enemies_exploded = {}
var fruits_placed = {}

func _ready() -> void:
	exploded.connect(add_enemy_exploded)
	fruit_placed.connect(edit_fruit_placed)
	
func add_enemy_exploded(_fruit, enemies_killed: Array[Node2D]):
	for enemy in enemies_killed:
		enemies_exploded[enemy.convoy_id] += 1
		
func edit_fruit_placed(f: Node2D):
	fruits_placed[f.get_instance_id()] = f.duplicate()
	print(fruits_placed)
	
func remove_fruit_placed(f: Node2D):
	print("to remove %s" % f.get_instance_id())
	fruits_placed.erase(f.get_instance_id())
	print(fruits_placed)
