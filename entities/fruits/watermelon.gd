extends Node2D

@export var radius: int = 200
@export var border_radius: float = 10.0
@export var border_color: Color = Color.DARK_RED
@export var border_width: float = 2.0
@onready var collision_shape = $Area2D/CollisionShape2D
@onready var sprite = $Sprite2D

func _draw() -> void:
	collision_shape.shape.radius = radius
	draw_circle(sprite.position, radius, border_color, false, border_width)

func _on_area_2d_area_entered(area: Area2D) -> void:
	print("enemy entered")
	draw_circle(sprite.position, radius, border_color, true, border_width)


func change_transparency():
	self.modulate.a = 0.5
