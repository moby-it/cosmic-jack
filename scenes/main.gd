extends Node2D

@onready var apple = preload("res://entities/apple.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _input(event) -> void:
	if(event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT):
		print("left mouse button clicked",event.position)
		var apple_scn = apple.instantiate()
		apple_scn.position = Vector2(event.position)
		self.add_child(apple_scn)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
