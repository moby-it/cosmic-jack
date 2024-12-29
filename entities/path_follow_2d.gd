extends PathFollow2D


@export var speed = 100
@export var density = 100

func _process(delta):
	progress += speed * delta
