extends Node2D

@onready var apple_scn = preload("res://entities/apple.tscn")
@onready var active_fruit_scn = $"Active Fruit"
enum FRUITS { APPLE = 0, WATERMELON }
var active_fruit = FRUITS.APPLE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _input(event) -> void:
	if(event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT):
		print("left mouse button clicked",event.position)
		var apple_scn = apple_scn.instantiate()
		apple_scn.position = Vector2(event.position)
		self.add_child(apple_scn)
	if (event is InputEventMouseMotion):
		active_fruit_scn.position = event.position
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
