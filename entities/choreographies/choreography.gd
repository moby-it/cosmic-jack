extends Node2D

@export var attributes: ChoreographyAttributes

func _ready() -> void:
	$Timer.wait_time = attributes.spawn_interval
	print(attributes.path)
	var path = load(attributes.path).instantiate()
	self.add_child(path)

func start_timer():
	$Timer.start()
