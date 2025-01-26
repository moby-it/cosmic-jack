# manages the active scene.

extends Node

signal change_scene
@onready var main_node: Node2D = self.get_tree().root.get_node("Main")
func _ready() -> void:
	change_scene.connect(on_change_scene)

func on_change_scene(node: Node2D):
	for n in main_node.get_children():
		n.queue_free()
	main_node.add_child(node)
