# apple triggers on enemy touch

extends Node2D

@export var explosive: Explosive
@export_multiline var tooltip_content: String

var exploding = false
var hovered = false

var tooltip: Tooltip = Tooltip.new()
@onready var area = $Area2D
func _draw() -> void:
	if explosive:
		explosive.draw_explosive_radius(self)

func _ready() -> void:
	if explosive:
		var area: Area2D = self.get_node("ExplosiveRadius")
		if area:
			area.area_entered.connect(enemy_entered)
		to_movable()
	else:
		tooltip.connect_tooltip_on_hover(self, tooltip_content)

func enemy_entered(a: Area2D) -> void:
	if a.get_parent().is_in_group("enemies") && not exploding:
		exploding = true
		explosive.start_explosion_timer(self)

func to_movable():
	area.mouse_entered.connect(func(): hovered = true)
	area.mouse_exited.connect(func(): hovered = false)
