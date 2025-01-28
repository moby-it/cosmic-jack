# apple triggers on enemy touch

extends Node2D

@export var explosive: Explosive

@onready var area = $Area2D

var exploding = false
var hovered = false

func _draw() -> void:
	explosive.draw_explosive_radius(self)

func _ready() -> void:
	var area: Area2D = self.get_node("ExplosiveRadius")
	area.area_entered.connect(enemy_entered)
	to_movable()

func enemy_entered(a: Area2D) -> void:
	if a.get_parent().is_in_group("enemies") && not exploding:
		exploding = true
		explosive.start_explosion_timer(self)

func to_movable():
	area.mouse_entered.connect(func(): hovered = true)
	area.mouse_exited.connect(func(): hovered = false)
