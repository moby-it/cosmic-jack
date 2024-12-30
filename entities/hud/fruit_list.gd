extends Node2D

signal fruit_selected

func _on_apple_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	fruit_selected.emit(0)

func _on_watermelon_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	fruit_selected.emit(1)
