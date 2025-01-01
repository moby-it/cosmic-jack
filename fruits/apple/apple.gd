# apple triggers on enemy touch

extends Node2D

@export var explosive: Explosive

func _ready() -> void:
	var area: Area2D = self.get_node("ExplosiveRadius")
	if area:
		area.area_entered.connect(enemy_entered)

func enemy_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("enemies"):
		explosive.start_explosion_timer(self)
