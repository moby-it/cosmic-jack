extends Node2D


@export var radius: float = 200
@export var border_radius: float = 10.0
@export var border_color: Color = Color.DARK_RED
@export var border_width: float = 2.0
@onready var collision_shape = $Area2D/CollisionShape2D
@onready var sprite = $Sprite2D

var filled = false

func _draw() -> void:
	collision_shape.shape.radius = radius * 10 # for some reason the radius need to be x10 in order to match the draw_circle
	draw_circle(sprite.position, radius, border_color, filled, border_width)
	
func change_transparency():
	self.modulate.a = 0.5


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("enemies"):
		filled = true
		self.queue_redraw()
