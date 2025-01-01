extends Node

signal fruit_selected

var available_fruits: Array[PackedScene] = [
	preload("res://fruits/apple/apple.tscn"),
	preload("res://fruits/watermelon/watermelon.tscn")
]

func create_fruit_list_hud(node: Node2D):
	for i in available_fruits.size():
		var fruit: Node2D = available_fruits[i].instantiate()
		var collider: Area2D = fruit.get_node("Area2D")
		collider.input_event.connect(func(): fruit_selected.emit(i))
		fruit.position.y = i * 100
		node.add_child(fruit)
