extends Resource
class_name Explosive

@export var radius: float = 0.0
@export var detonation_delay: float = 1.0

var border_color: Color = Color.RED
var border_width: float = 2.0
var timer: Timer
var exploding = false

func draw_explosive_radius(node: Node2D) -> void:
	_add_area(node, radius)
	node.draw_circle(node.get_node("Sprite2D").position, radius, border_color, false, border_width)
	node.queue_redraw()

func start_explosion_timer(node: Node2D) -> void:
	var timer_line: Node2D = load("res://fruits/timer_line.tscn").instantiate()
	timer_line.duration = detonation_delay
	timer_line.timeout.connect(explode.bind(node))
	timer = timer_line.get_node("Timer")
	timer.wait_time = detonation_delay
	node.add_child(timer_line)
	timer.start()

func _add_area(node: Node2D, r: float):
	if is_instance_valid(node.get_node("Area2D")):
		node.get_node("Area2D").queue_free() # remove smaller collision shape
	
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
	var area: Area2D = fruit.get_node("ExplosiveRadius")
	for a in area.get_overlapping_areas():
		var enemy = a.get_parent()
		if enemy.is_in_group("enemies"):
			# we have to remove the pathFollow that is the parent of enemy
			enemy.get_parent().queue_free()
	ExplosionBus.exploded.emit(fruit)
	fruit.queue_free()
