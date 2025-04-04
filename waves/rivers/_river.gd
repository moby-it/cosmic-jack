extends PathFollow2D

## in beats
@export var duration: int  # Duration in beats
signal enemy_passed

func _ready() -> void:
	self.loop = false

func _process(delta):
	if not AudioManager.paused:
		progress_ratio += delta / (duration * AudioManager.seconds_per_beat)
		if progress_ratio >= 1.0:
			enemy_passed.emit()
			queue_free()
