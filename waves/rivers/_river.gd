extends PathFollow2D

@export var speed = 200
var speed_modifier = 4
signal enemy_passed

func _process(delta):
	progress += speed * delta * speed_modifier
	if progress_ratio >= 1.0:
		enemy_passed.emit()
		self.queue_free()
