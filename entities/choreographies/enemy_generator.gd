extends Path2D

@onready var timer = get_parent().get_node("Timer")
@onready var spawn_interval = get_parent().spawn_interval
@onready var count = get_parent().count
@onready var speed = get_parent().speed
@onready var enemy_scn = load(get_parent().scn_path)

var curr_enemies = 0

func _on_timer_timeout() -> void:
	if curr_enemies >= count:
		timer.stop()
		return
	curr_enemies += 1
	print("should create enemy")
	var pf = create_path_follow()
	self.add_child(pf)

func create_path_follow() -> Node:
	var path_follow = load("res://entities/choreographies/path_follow.tscn").instantiate()
	path_follow.speed = speed
	var scn = enemy_scn.instantiate()
	scn.get_node("Area2D").get_node("CollisionShape2D").disabled = true # disable colision for preview enemies
	scn.get_node("Sprite2D").modulate.a = 0.5
	path_follow.add_child(scn)
	return path_follow
