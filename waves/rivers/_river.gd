extends PathFollow2D
class_name River

@export var speed: int = 0

signal enemy_passed

func _process(delta):
	progress += speed * delta
	if progress_ratio == 1.0:
		enemy_passed.emit()
		self.queue_free()
