extends PathFollow2D

## in beats
@export var duration = 12  # Duration in beats
var paused = false
signal enemy_passed
signal removed

func _ready() -> void:
	removed.connect(func(): self.queue_free())
	# BpmManager.on_beat.connect(move_on_beat) # moving on beat, instead of a continous movement

# func move_on_beat(_i: int):
# 	if not paused:
# 		progress_ratio += 1.0 / duration
# 		if progress_ratio >= 1.0:
# 			enemy_passed.emit()
# 			queue_free()
	
func _process(delta):
	if not paused:
		progress_ratio += delta / (duration * BpmManager.seconds_per_beat)
		if progress_ratio >= 1.0:
			enemy_passed.emit()
			queue_free()
