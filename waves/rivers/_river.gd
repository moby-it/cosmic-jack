extends PathFollow2D

## in beats
@export var duration = 12  # Duration in beats
var paused = false
signal enemy_passed

func _ready() -> void:
	self.loop = false
	
func _process(delta):
	if not paused:
		progress_ratio += delta / (duration * BpmManager.seconds_per_beat)
		if progress_ratio >= 1.0:
			enemy_passed.emit()
			queue_free()
