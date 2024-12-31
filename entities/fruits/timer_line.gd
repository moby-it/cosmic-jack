extends Node2D

signal timeout

@export var duration = 2.0
@onready var timer = $Timer
@onready var line = $Line2D
@onready var initial_width = line.points[1].x

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(duration)
	timer.wait_time = duration

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not timer.is_stopped():
		var progress = timer.time_left / duration
		line.points[1].x = initial_width * progress

func _on_timer_timeout() -> void:
		timeout.emit()
		self.queue_free()
