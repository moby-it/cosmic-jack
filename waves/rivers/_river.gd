extends PathFollow2D

@export var speed: int = 0

func _process(delta):
	progress += speed * delta
	if not get_parent().get_parent().is_preview && progress_ratio == 1.0:
		Health.enemy_passed.emit()
		self.queue_free()
