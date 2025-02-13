extends Node

var hp_score_mod = 100

var fruit_score = {
	"apple": 40,
	"watermelon": 10,
	"cherries": 10
}


func calc_score(hp: int, ammo: Dictionary) -> int:
	var fs = 0
	for k in ammo:
		fs += ammo[k] * fruit_score[k]
	return (hp * hp_score_mod) + fs
