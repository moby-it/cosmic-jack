extends Node2D

@export var explosive: Explosive
@export_multiline var tooltip_content: String

var tooltip: Tooltip = Tooltip.new()

var exploding = false
var hovered = false

@onready var area = $Area2D

func _draw() -> void:
	if explosive:
		explosive.draw_explosive_radius(self)

func _ready() -> void:
	if explosive:
		var area: Area2D = self.get_node("ExplosiveRadius")
		ExplosionBus.exploded.connect(_on_explosion)
		to_movable()
	else:
		tooltip.connect_tooltip_on_hover(self, tooltip_content)

# watermelon triggers on adjacent explosion
func _on_explosion(fruit: Node) -> void:
	var fruit_area: Area2D = fruit.get_node("ExplosiveRadius")
	var my_area: Area2D = self.get_node("ExplosiveRadius")
	if my_area.overlaps_area(fruit_area) && not exploding:
		exploding = true
		explosive.start_explosion_timer(self)
		
func to_movable():
	area.mouse_entered.connect(func(): hovered = true)
	area.mouse_exited.connect(func(): hovered = false)
