extends Node

# constants
var available_fruits = {
	"apple": preload("res://fruits/apple/apple.tscn"),
	"watermelon": preload("res://fruits/watermelon/watermelon.tscn"),
	"cherry": preload("res://fruits/cherry/cherry.tscn")
}

var available_fruits_png = {
	"apple": preload("res://fruits/apple/apple.png"),
	"watermelon": preload("res://fruits/watermelon/watermelon.png"),
	"cherry": preload("res://fruits/cherry/cherry.png")
}

signal level_completed
signal wave_completed
signal fruit_placed
signal exploded
signal fruit_selected

var enemies_exploded = {}
var fruits_placed = {}

func _ready() -> void:
	exploded.connect(add_enemy_exploded)
	
func add_enemy_exploded(_fruit, enemies_killed: Array[Node2D]):
	for enemy in enemies_killed:
		var c_enemies_exploded: Array = enemies_exploded[enemy.get_meta("convoy_id")]
		var e_id = enemy.get_instance_id()
		if not c_enemies_exploded.has(e_id):
			c_enemies_exploded.push_back(e_id)
		
func edit_fruit_placed(f: Node2D):
	fruits_placed[f.get_instance_id()] = f.duplicate()
	
func remove_fruit_placed(f: Node2D):
	fruits_placed.erase(f.get_instance_id())

func can_place_fruit(n: String, idx: int):
	for key in fruits_placed:
		var f: Node2D = fruits_placed[key]
		if f.get_meta("hud_idx") == idx and f.get_meta("name") == n:
			return false
	return true

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

func create_fruit_list_hud(node: VBoxContainer, wave: Wave):
	if not is_instance_valid(node):
		return
	#print("creating new fruit list", ammo)
	for key in available_fruits:
		if not wave.ammo.get_fruits()[key]:
			continue
		var container = HBoxContainer.new()
		container.add_theme_constant_override("separation", 20)
		container.set_meta("name", key)
		
		
		for a in wave.ammo.get_fruits()[key]:
			# render fruit texture
			var fruit = TextureRect.new()
			fruit.name = "texture"
			fruit.texture = available_fruits_png[key]
			fruit.mouse_default_cursor_shape = Control.CURSOR_DRAG
			fruit.gui_input.connect(func(event): if Utils.is_mouse_left_down(event) and can_place_fruit(key, a): fruit_selected.emit(key, a))
			container.add_child(fruit)		
		node.add_child(container)

func create_fruit(n: String) -> Node2D:
	var fruit: Node2D = available_fruits[n].instantiate()
	fruit.set_meta("name", n)
	fruit.set_meta("placed", false)
	fruit.remove_from_group("fruits")
	fruit.explosive.add_explosive_radius(fruit,fruit.explosive.radius)
	return fruit
	
func find_fruits_under_cursor() -> Array[Node]:
	var placed_fruits = get_tree().get_nodes_in_group("fruits").filter(func (f): return f.hovered)
	return placed_fruits
