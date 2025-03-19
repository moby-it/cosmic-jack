extends Node

signal fruit_selected

var available_fruits = {
	"apple": preload("res://fruits/apple/apple.tscn"),
	"watermelon": preload("res://fruits/watermelon/watermelon.tscn"),
	"cherry": preload("res://fruits/cherry/cherry.tscn")
}
var tooltips = {
	"apple":"Explodes 4 beats after enemy touch.",
	"watermelon":"Explodes 2 beat after an overlapping explosion.",
	"cherry":"Explodes on next beat after enemy touch."
}
var available_fruits_png = {
	"apple": preload("res://fruits/apple/apple.png"),
	"watermelon": preload("res://fruits/watermelon/watermelon.png"),
	"cherry": preload("res://fruits/cherry/cherry.png")
}

var ammo = {}

var ammo_labels = {}

func find_first_fruit_with_ammo(wave: Wave):
	var a = wave.ammo.get_fruits()
	for k in a:
		if a[k]:
			return k
	return null
		

func create_fruit_list_hud(node: VBoxContainer, wave: Wave):
	if not is_instance_valid(node):
		return
	ammo = wave.ammo.get_fruits()
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
			fruit.gui_input.connect(func(event): if Utils.is_mouse_left_down(event): fruit_selected.emit(key, a))
			container.add_child(fruit)		
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

func create_fruit(name: String) -> Node2D:
	var fruit: Node2D = available_fruits[name].instantiate()
	fruit.set_meta("name", name)
	fruit.remove_from_group("fruits")
	fruit.explosive.add_explosive_radius(fruit,fruit.explosive.radius)
	return fruit
	
func find_fruits_under_cursor() -> Array[Node]:
	var placed_fruits = get_tree().get_nodes_in_group("fruits").filter(func (f): return f.hovered)
	return placed_fruits
