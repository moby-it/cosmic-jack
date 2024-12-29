extends Node2D

@onready var apple_scn = preload("res://entities/apple.tscn")
@onready var watermelon_scn = preload("res://entities/watermelon.tscn")
@onready var active_fruit_scn = $"Active Fruit"
enum FRUITS { APPLE = 0, WATERMELON }
var active_fruit = FRUITS.APPLE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _input(event) -> void:
	if(event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && active_fruit_scn.visible):
		place_fruit(event.position)
	if (event is InputEventMouseMotion):
		active_fruit_scn.position = event.position
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func place_fruit(position: Vector2) -> void:
	match active_fruit:
		FRUITS.APPLE:
			var apple_scn = apple_scn.instantiate()
			apple_scn.position = Vector2(position)
			self.add_child(apple_scn)
		FRUITS.WATERMELON:
			var watermelon_scn = watermelon_scn.instantiate()
			watermelon_scn.position = Vector2(position)
			self.add_child(watermelon_scn)

func _on_play_area_mouse_entered() -> void:
	active_fruit_scn.visible = true
	pass # Replace with function body.


func _on_play_area_mouse_exited() -> void:
	active_fruit_scn.visible = false
	pass # Replace with function body.


func _on_hud_fruit_selected(f: int) -> void:
	active_fruit = f
	match f:
		0:
			active_fruit_scn.texture = load("res://assets/red-apple-with-radius_opaque.png")
		1: 
			active_fruit_scn.texture = load("res://assets/watermelon_circle_opaue.png")
	pass # Replace with function body.
