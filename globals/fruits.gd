extends Node

signal fruit_selected

enum FRUITS { apple = 0, watermelon }

var available_fruits = {
	"apple": preload("res://fruits/apple/apple.tscn"),
	"watermelon": preload("res://fruits/watermelon/watermelon.tscn")
}
var ammo = {
	"apple": 2,
	"watermelon": 2
}
var ammo_labels = {}

func create_fruit_list_hud(node: Node2D):
	for key in available_fruits:
		var i = FRUITS[key]
		var fruit: Node2D = available_fruits[key].instantiate()
		var label = Label.new()
		label.text = str(ammo[key])
		label.position.x = 50
		fruit.add_child(label)
		ammo_labels[key] = label
		var area: Area2D = fruit.get_node("Area2D")
		area.input_event.connect(func(viewport,event, idx): fruit_selected.emit(key))
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
	
	
	
