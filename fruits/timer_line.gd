extends Node2D

signal timeout

@export var duration = 2.0
@onready var timer = $Timer
@onready var line = $Line2D
@onready var initial_width = line.points[1].x

func _ready() -> void:
	timer.wait_time = duration

func _process(delta: float) -> void:
	if not timer.is_stopped():
		var progress = timer.time_left / duration
		line.points[1].x = initial_width * progress

func _on_timer_timeout() -> void:
		timeout.emit()
		self.queue_free()
