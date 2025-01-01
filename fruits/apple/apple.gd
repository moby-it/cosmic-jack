# apple triggers on enemy touch

extends Node2D

@export var explosive: Explosive
var exploding = false
func _draw() -> void:
	if explosive:
		explosive.draw_explosive_radius(self)

func _ready() -> void:
	var area: Area2D = self.get_node("ExplosiveRadius")
	if area:
		area.area_entered.connect(enemy_entered)

func enemy_entered(a: Area2D) -> void:
	if a.get_parent().is_in_group("enemies") && not exploding:
		exploding = true
		explosive.start_explosion_timer(self)
