extends PathFollow2D

@export var speed: float = 300.0
var paused = false

signal enemy_passed

func _process(delta):
	speed = 200
	if not paused:
		progress += speed * (delta * 2.5) 
		if progress_ratio >= 1.0:
			enemy_passed.emit()
			self.queue_free()
