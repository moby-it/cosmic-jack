extends Node2D

@export var radius: float = 200

var border_color: Color = Color.DARK_RED
var border_width: float = 2.0

@onready var collision_shape = $Area2D/CollisionShape2D
@onready var sprite = $Sprite2D
@onready var timer = $TimerLine/Timer
@onready var line = $TimerLine

func _draw() -> void:
	collision_shape.shape.radius = radius
	draw_circle(sprite.position, radius, border_color, false, border_width)
	
func change_transparency():
	self.modulate.a = 0.5

# trigger explosion timeout when an enemy enters the fruit
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("enemies") && is_instance_valid(timer) && timer.is_stopped():
		timer.start()
		line.visible = true

func exploded() -> void:
	Explosion.explosion(self)
	self.queue_free()
