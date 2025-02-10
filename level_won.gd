extends Node2D

@export var score = 0
var hp = 0
@onready var label = $ColorRect/Label

func _ready() -> void:
	for f in Fruits.fruits:
		var s = Fruits.ammo[f] * Fruits.fruit_score[f]
		label.text += "%s: %s * %s = %s \n" % [f, Fruits.ammo[f], Fruits.fruit_score[f], str(s) ]
	label.text += "Health: %s * %s = %s \n" % [hp, Utils.hp_score_mod, str(hp * Utils.hp_score_mod)]
	label.text += "Score: %s" % score
