extends Node2D

@export var explosive: Explosive

@onready var area = $Area2D

var exploding = false
var hovered = false

func _draw() -> void:
	explosive.draw_explosive_radius(self)

func _ready() -> void:
	var area: Area2D = self.get_node("ExplosiveRadius")
	ExplosionBus.exploded.connect(_on_explosion)
	to_movable()

# watermelon triggers on adjacent explosion
func _on_explosion(fruit: Node, enemies_exploded: int) -> void:
	var fruit_area: Area2D = fruit.get_node("ExplosiveRadius")
	var my_area: Area2D = self.get_node("ExplosiveRadius")
	if my_area.overlaps_area(fruit_area) && not exploding:
		exploding = true
		explosive.start_explosion_timer(self)
		
func to_movable():
	area.mouse_entered.connect(func(): hovered = true)
	area.mouse_exited.connect(func(): hovered = false)
