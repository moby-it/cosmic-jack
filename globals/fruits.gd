extends Node

signal fruit_selected

var available_fruits: Array[PackedScene] = [
	preload("res://fruits/apple/apple.tscn"),
	preload("res://fruits/watermelon/watermelon.tscn")
]

func create_fruit_list_hud(node: Node2D):
	for i in available_fruits.size():
		var fruit: Node2D = available_fruits[i].instantiate()
		var area: Area2D = fruit.get_node("Area2D")
		area.input_event.connect(func(viewport,event, idx): fruit_selected.emit(i))
		fruit.position.y = i * 100
		node.add_child(fruit)
