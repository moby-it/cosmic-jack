extends Node2D

@export var radius: float = 250

var border_color: Color = Color.DARK_RED
var border_width: float = 2.0

@onready var collision_shape = $Area2D/CollisionShape2D
@onready var sprite = $Sprite2D
@onready var timer = $TimerLine/Timer
@onready var line = $TimerLine

func _draw() -> void:
	collision_shape.shape.radius = radius
	draw_circle(sprite.position, radius, border_color, false, border_width)
	
func _ready() -> void:
	Explosion.exploded.connect(_on_explosion)

func change_transparency():
	self.modulate.a = 0.5

func _on_explosion(fruit: Node) -> void:
	var fruit_area: Area2D = fruit.get_node("Area2D")
	var my_area: Area2D = $Area2D
	if my_area.overlaps_area(fruit_area) && is_instance_valid(timer) && timer.is_stopped():
		timer.start()
		line.visible = true

func _on_timer_line_timeout() -> void:
	# write explosion logic
	self.queue_free()

func exploded() -> void:
	Explosion.explosion(self)
	self.queue_free()
