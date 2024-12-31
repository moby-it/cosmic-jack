extends Node2D

@export var radius: float = 150

var border_color: Color = Color.DARK_RED
var border_width: float = 2.0

@onready var collision_shape = $Area2D/CollisionShape2D
@onready var sprite = $Sprite2D
@onready var timer = $TimerLine/Timer
@onready var line = $TimerLine

func _draw() -> void:
	collision_shape.shape.radius = radius * 10 # for some reason the radius need to be x10 in order to match the draw_circle
	draw_circle(sprite.position, radius, border_color, false, border_width)
	
func change_transparency():
	self.modulate.a = 0.5

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("enemies") && is_instance_valid(timer) && timer.is_stopped():
		timer.start()
		line.visible = true


func _on_timer_line_timeout() -> void:
	# write explosion logic
	self.queue_free()
