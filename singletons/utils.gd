extends Node

var hp_score_mod = 100

func is_mouse_left(event) -> bool:
	return event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.is_pressed()
func is_mouse_right(event) -> bool:
	return event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_RIGHT && event.is_pressed()
func is_mouse_move(event) -> bool:
	return event is InputEventMouseMotion

func calc_score(hp: int, ammo: Dictionary) -> int:
	var fruit_score = 0
	for k in ammo:
		fruit_score += ammo[k] * Fruits.fruit_score[k]
	return (hp * hp_score_mod) + fruit_score
