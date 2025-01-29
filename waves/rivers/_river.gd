extends PathFollow2D

@export var speed: float = 300.0
var paused = false
signal enemy_passed
signal removed

func _ready() -> void:
	removed.connect(func(): self.queue_free())

func _process(delta):
	speed = 200
	if not paused:
		progress += speed * (delta * 2.5) 
		if progress_ratio >= 1.0:
			enemy_passed.emit()
			self.queue_free()
