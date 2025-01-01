# watermelon triggers on adjacent explosion

extends Node2D

@export var explosive: Explosive

func _ready() -> void:
	ExplosionBus.exploded.connect(_on_explosion)

func _on_explosion(fruit: Node) -> void:
	var fruit_area: Area2D = fruit.get_node("ExplosiveRadius")
	var my_area: Area2D = self.get_node("ExplosiveRadius")
	if my_area.overlaps_area(fruit_area):
		explosive.start_explosion_timer(self)
