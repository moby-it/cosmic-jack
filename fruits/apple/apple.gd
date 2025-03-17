# apple triggers on wave init

extends Node2D

@export var explosive: Explosive

@onready var area = $Area2D

var exploding = false
var hovered = false

func _draw() -> void:
	explosive.draw_explosive_radius(self)

func _ready() -> void:
	to_movable()
	# Connect to level to detect when wave is initialized
	var level = get_tree().get_first_node_in_group("level")
	if level:
		# Start explosion countdown when wave resolving begins
		level.wave_resolving.connect(on_wave_resolving)

func on_wave_resolving() -> void:
	if not exploding:
		exploding = true
		explosive.start_explosion_timer(self)

func to_movable():
	area.mouse_entered.connect(func(): hovered = true)
	area.mouse_exited.connect(func(): hovered = false)
