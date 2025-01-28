extends Node

signal fruit_selected

var available_fruits = {
	"apple": preload("res://fruits/apple/apple.tscn"),
	"watermelon": preload("res://fruits/watermelon/watermelon.tscn")
}
var tooltips = {
	"apple":"Explodes 2 seconds after enemy touch.",
	"watermelon":"Explodes 1 second after an overlapping explosion."
}
var available_fruits_png = {
	"apple": preload("res://fruits/apple/apple.png"),
	"watermelon": preload("res://fruits/watermelon/watermelon.png")
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

func create_fruit_list_hud(node: VBoxContainer):
	if not is_instance_valid(node):
		return
	for key in available_fruits:
		var container = HBoxContainer.new()
		container.add_theme_constant_override("separation", 20)
		var fruit = TextureRect.new()
		fruit.texture = available_fruits_png[key]
		fruit.gui_input.connect(func(event): if Utils.is_mouse_left(event): fruit_selected.emit(key))
		container.add_child(fruit)
		
		var label = Label.new()
		label.text = str(ammo[key])
		ammo_labels[key] = label
		container.add_child(label)
		
		var tooltip = Label.new()
		tooltip.text = tooltips[key]
		tooltip.add_theme_font_size_override("font_size",24)
		container.add_child(tooltip)
		
		node.add_child(container)

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
