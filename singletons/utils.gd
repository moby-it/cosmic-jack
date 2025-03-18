extends Node

func is_mouse_right(event) -> bool:
	return event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_RIGHT && event.is_pressed()

func is_mouse_left_down(event) -> bool:
	return event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.is_pressed()
	
func is_mouse_left_up(event) -> bool:
	return event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && not event.is_pressed()
