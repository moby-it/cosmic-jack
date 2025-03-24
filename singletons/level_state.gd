extends Node

signal level_completed
signal wave_completed
signal fruit_placed
signal exploded

var enemies_exploded = {}
var fruits_placed = {}

func _ready() -> void:
	exploded.connect(add_enemy_exploded)
	
func add_enemy_exploded(_fruit, enemies_killed: Array[Node2D]):
	for enemy in enemies_killed:
		var convoy_enemies_exploded: Array = enemies_exploded[enemy.get_meta("convoy_id")]
		var e_id = enemy.get_instance_id()
		if not convoy_enemies_exploded.has(e_id):
			convoy_enemies_exploded.push_back(e_id)
		
func edit_fruit_placed(f: Node2D):
	fruits_placed[f.get_instance_id()] = f.duplicate()
	
func remove_fruit_placed(f: Node2D):
	fruits_placed.erase(f.get_instance_id())

func wave_enemies_exploded(wave: Wave) -> bool:
	return wave.convoys.all(convoy_enemies_exploded)
	
func convoy_enemies_exploded(convoy: Convoy) -> bool:
	return len(LevelState.enemies_exploded[convoy.get_instance_id()]) >= convoy.count

func all_convoys_rendered(wave: Wave) -> bool:
	return wave.convoys.all(func(c): return c.rendered)

func largest_convoy_duration(wave: Wave) -> int:
	return wave.convoys.map(func(c): return c.duration).max()

func disable_fruit_collision(f: Node2D):
	var area: Area2D = f.get_node("ExplosiveRadius")
	area.monitoring = false

func enable_fruit_collision(f: Node2D):
	var area: Area2D = f.get_node("ExplosiveRadius")
	area.monitoring = true
