extends Node2D

@export var radius: int = 150

var border_color: Color = Color.DARK_RED
var border_width: float = 2.0

@onready var collision_shape = $Area2D/CollisionShape2D
@onready var sprite = $Sprite2D

var filled = false

func _draw() -> void:
	collision_shape.shape.radius = radius
	draw_circle(sprite.position, radius, Color.DARK_RED, filled, 2.0)

func change_transparency():
	self.modulate.a = 0.5

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("enemies"):
		filled = true
		self.queue_redraw()
