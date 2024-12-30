extends Path2D

# I should add a pathfollow under the Path2D for each enemy that needs to spawn.
# Path follow needs to also include the enemy scene as a child
# On each process tick we should set the progress of each PathFollow

var croc_scn = load("res://entities/choreographies/path_progress.tscn")
@onready var timer = $Timer
var curr_enemies = 0
@export var speed = 100
@export var spawn_interval = 0.5
@export var count = 10

func _ready() -> void:
	timer.wait_time = spawn_interval
	curr_enemies += 1
	var scn = croc_scn.instantiate()
	self.add_child(scn)
	scn = croc_scn.instantiate()

func _process(delta):
	pass
	#progress += speed * delta


func _on_timer_timeout() -> void:
	if curr_enemies >= count:
		$Timer.stop()
		return
	curr_enemies += 1
	var scn = croc_scn.instantiate()
	self.add_child(scn)
