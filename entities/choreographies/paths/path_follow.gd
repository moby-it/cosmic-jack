extends PathFollow2D

@export var speed: int = 0
@onready var attributes: ChoreographyAttributes = get_parent().get_parent().attributes

# Called when the node enters the scene tree for the first time.
func _process(delta):
	progress += speed * delta
	if not attributes.is_preview && progress_ratio == 1.0:
		Health.enemy_passed.emit()
		self.queue_free()
