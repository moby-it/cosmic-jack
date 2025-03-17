# apple triggers on enemy touch

extends Node2D

@export var explosive: Explosive

@onready var area = $Area2D

var exploding = false
var hovered = false

func _draw() -> void:
	explosive.draw_explosive_radius(self)

func _ready() -> void:
	LevelManager.wave_resolving.connect(trigger_explosion)
	to_movable()

func trigger_explosion() -> void:
	exploding = true
	explosive.start_explosion_timer(self)

func to_movable():
	area.mouse_entered.connect(func(): hovered = true)
	area.mouse_exited.connect(func(): hovered = false)
