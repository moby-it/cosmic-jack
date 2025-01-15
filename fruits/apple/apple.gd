# apple triggers on enemy touch

extends Node2D

@export var explosive: Explosive
var exploding = false
var hovered = false

func _draw() -> void:
	if explosive:
		explosive.draw_explosive_radius(self)

func _ready() -> void:
	var area: Area2D = self.get_node("ExplosiveRadius")
	if area:
		area.area_entered.connect(enemy_entered)
		area.mouse_entered.connect(_mouse_entered)
		area.mouse_exited.connect(_mouse_exited)

func enemy_entered(a: Area2D) -> void:
	if a.get_parent().is_in_group("enemies") && not exploding:
		exploding = true
		explosive.start_explosion_timer(self)


func _mouse_entered() -> void:
	hovered = true

func _mouse_exited() -> void:
	hovered = false
	
