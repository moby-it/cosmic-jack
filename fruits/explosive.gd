extends Resource
class_name Explosive

@export var radius: float = 0.0
## in beats
@export var detonation_delay: float = 1.0

var border_color: Color = Color.RED
var border_width: float = 2.0
var timer: Timer

func draw_explosive_radius(node: Node2D) -> void:
	_add_explosive_radius(node, radius)
	node.draw_circle(node.get_node("Sprite2D").position, radius, border_color, false, border_width)

func start_explosion_timer(node: Node2D) -> void:
	# delay is always in sync with bpm
	var delay = (detonation_delay * BpmManager.seconds_per_beat) + BpmManager.time_to_next_beat
	var timer_line: Node2D = load("res://fruits/timer_line.tscn").instantiate()
	timer_line.duration = delay
	timer_line.timeout.connect(explode.bind(node))
	timer = timer_line.get_node("Timer")
	timer.wait_time = delay
	node.add_child(timer_line)
	timer.start()

func _add_explosive_radius(node: Node2D, r: float):
	var area: Area2D = Area2D.new()
	area.name = "ExplosiveRadius"
	area.set_collision_layer_value(1, true)
	area.set_collision_mask_value(1, true)
	area.set_collision_mask_value(2, true)
	var collider = CollisionShape2D.new()
	collider.shape = CircleShape2D.new()
	collider.shape.radius = r
	area.add_child(collider)
	node.add_child(area)

func explode(fruit: Node2D):
	var enemies_killed = {}
	var area: Area2D = fruit.get_node("ExplosiveRadius")
	for a in area.get_overlapping_areas():
		var enemy = a.get_parent()
		if enemy.is_in_group("enemies"):
			# we have to remove the pathFollow that is the parent of enemy
			enemies_killed[enemy.get_instance_id()] = null
			var pf = enemy.get_parent()
			pf.queue_free()
	ExplosionBus.exploded.emit(fruit, enemies_killed)
	fruit.queue_free()
