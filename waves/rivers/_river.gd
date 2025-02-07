extends PathFollow2D

@export var duration = 12  # Duration in beats
var paused = false
signal enemy_passed
signal removed

func _ready() -> void:
	removed.connect(func(): self.queue_free())

func _process(delta):
	if not paused:
		progress_ratio += delta / (duration * BpmManager.seconds_per_beat)
		if progress_ratio >= 1.0:
			enemy_passed.emit()
			queue_free()
