extends PathFollow2D

## in beats
@export var duration: int  # Duration in beats
signal enemy_passed
var paused = false

func _ready() -> void:
	self.loop = false
	AudioManager.on_pause.connect(func():
		if AudioManager.paused:
			paused = true
		else:
			var f = func(i): paused = false
			AudioManager.on_beat.connect(f, CONNECT_ONE_SHOT)
		)

func _process(delta):
	if not paused:
		progress_ratio += delta / (duration * AudioManager.seconds_per_beat)
		if progress_ratio >= 1.0:
			enemy_passed.emit()
			queue_free()
