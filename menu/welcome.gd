extends Node2D

@onready var close = $close

signal on_close

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close.gui_input.connect()

func handle_close(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		on_close.emit()
	
