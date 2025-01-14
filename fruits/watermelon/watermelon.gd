# watermelon triggers on adjacent explosion

extends Node2D

@export var explosive: Explosive
var exploding = false
var hovered = false
func _draw() -> void:
	if explosive:
		explosive.draw_explosive_radius(self)

func _ready() -> void:
	if explosive:
		var area: Area2D = self.get_node("ExplosiveRadius")
		ExplosionBus.exploded.connect(_on_explosion)
		area.mouse_entered.connect(_mouse_entered)
		area.mouse_exited.connect(_mouse_exited)

func _on_explosion(fruit: Node) -> void:
	var fruit_area: Area2D = fruit.get_node("ExplosiveRadius")
	var my_area: Area2D = self.get_node("ExplosiveRadius")
	if my_area.overlaps_area(fruit_area) && not exploding:
		exploding = true
		explosive.start_explosion_timer(self)


func _mouse_entered() -> void:
	hovered = true

func _mouse_exited() -> void:
	hovered = false
