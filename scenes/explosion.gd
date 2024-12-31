extends Node

signal exploded

func explosion(fruit: Node):
	exploded.emit(fruit)
	var area: Area2D = fruit.get_node("Area2D")
	for a in area.get_overlapping_areas():
		var enemy = a.get_parent()
		if enemy.is_in_group("enemies"):
			# we have to remove the pathFollow that is the parent of enemy
			enemy.get_parent().queue_free() 
