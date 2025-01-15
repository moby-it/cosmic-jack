extends Node2D

var hp = 3
@onready var hp_label = $HP
signal health_depleted

func _ready() -> void:
	Health.connect("enemy_passed", reduce_hp)
	Health.reset.connect(reset)

func reduce_hp():
	if hp > 0:
		hp -= 1
		hp_label.text = str(hp)
		if hp == 0:
			health_depleted.emit()

func reset():
	hp = 3
	hp_label.text = str(hp)
