extends Node


func is_mouse_left(event) -> bool:
	return event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.is_pressed()
func is_mouse_right(event) -> bool:
	return event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_RIGHT && event.is_pressed()
func is_mouse_move(event) -> bool:
	return event is InputEventMouseMotion
