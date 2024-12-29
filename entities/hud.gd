extends Node2D

signal fruit_selected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_apple_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	print(event)
	fruit_selected.emit(0)
	pass # Replace with function body.


func _on_watermelon_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	print(event)
	
	fruit_selected.emit(1)
	pass # Replace with function body.
