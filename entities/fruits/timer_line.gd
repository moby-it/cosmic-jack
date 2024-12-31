extends Node2D

@export var duration: float = 2.0
@onready var timer = $Timer
@onready var line = $Line2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = duration

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not timer.paused:
		line.width -= duration / delta
	#if line.width <= 0:
		#self.queue_free()
