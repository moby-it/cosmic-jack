extends Node

signal fruit_selected

enum FRUITS { apple = 0, watermelon }

var available_fruits = {
	"apple": preload("res://fruits/apple/apple.tscn"),
	"watermelon": preload("res://fruits/watermelon/watermelon.tscn")
}
var initial_ammo = {
	"apple": 4,
	"watermelon": 6
}

var fruit_score = {
	"apple": 20,
	"watermelon": 10
}

var ammo = initial_ammo

var ammo_labels = {}

func create_fruit_list_hud(node: Node2D):
	if not is_instance_valid(node):
		return
	for key in available_fruits:
		var i = FRUITS[key]
		var fruit: Node2D = available_fruits[key].instantiate()
		var label = Label.new()
		label.text = str(ammo[key])
		label.position.x = 50
		fruit.add_child(label)
		ammo_labels[key] = label
		var area: Area2D = fruit.get_node("Area2D")
		area.input_event.connect(func(viewport,event, idx): if Utils.is_mouse_left(event): fruit_selected.emit(key))
		fruit.position.y = i * 100
		fruit.explosive = null
		node.add_child(fruit)

func can_place_fruit(fruit: String) -> bool:
	return ammo[fruit] > 0

func reduce_fruit_ammo(fruit: String) -> void:
	if ammo[fruit] <= 0:
		push_error("cannot reduce fruit ammo")
	ammo[fruit] -= 1
	ammo_labels[fruit].text = str(ammo[fruit])

func add_fruit_ammo(fruit: String):
	ammo[fruit] += 1
	ammo_labels[fruit].text = str(ammo[fruit])

func create_fruit(active_fruit_name: String) -> Node2D:
	var fruit: Node2D = available_fruits[active_fruit_name].instantiate()
	fruit.name = active_fruit_name
	fruit.explosive.draw_explosive_radius(fruit)
	return fruit

func reset():
	ammo = initial_ammo

func find_fruits_under_cursor() -> Array[Node]:
	var placed_fruits = get_tree().get_nodes_in_group("fruits").filter(func (f): return f.hovered)
	return placed_fruits
