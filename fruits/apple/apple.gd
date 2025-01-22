# apple triggers on enemy touch

extends Node2D

@export var explosive: Explosive
@export_multiline var tooltip_content: String

var tooltip: Tooltip = Tooltip.new()

func _draw() -> void:
	if explosive:
		explosive.draw_explosive_radius(self)

func _ready() -> void:
	# default behavior if fruit is explosive
	if explosive:
		var area: Area2D = self.get_node("ExplosiveRadius")
		if area:
			# wiring up the explosive behavior of the apple
			area.area_entered.connect(enemy_entered)
			explosive.to_movable(area)
	else:
		# non explosive fruits have their tooltip shown on hover
		tooltip.connect_tooltip_on_hover(self, tooltip_content)

func enemy_entered(a: Area2D) -> void:
	if a.get_parent().is_in_group("enemies") && not explosive.exploding:
		explosive.exploding = true
		explosive.start_explosion_timer(self)
