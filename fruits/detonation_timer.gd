extends Node2D

signal timeout

var duration = 2.0
@onready var label = $Label

func _ready() -> void:
	label.text = str(int(duration))
	AudioManager.on_beat.connect(_on_beat)

func _on_beat(_i: int):
		duration -= 1
		label.text = str(int(duration))
		if duration <= 0:
			timeout.emit()
			self.queue_free()
