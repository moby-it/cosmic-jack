extends Node

var hp_score_mod = 100


func calc_score(hp: int, ammo: Dictionary) -> int:
	var fruit_score = 0
	for k in ammo:
		fruit_score += ammo[k] * Fruits.fruit_score[k]
	return (hp * hp_score_mod) + fruit_score
