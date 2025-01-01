extends Resource
class_name Explosive

@export var radius: float = 0.0
@export var delay: float = 1.0

var border_color: Color = Color.DARK_RED
var border_width: float = 2.0
var timer: Timer

func draw_explosive_radius(node: Node2D) -> void:
	_add_area(node, radius)
	node.draw_circle(node.get_node("Sprite2D").position, radius, border_color, false, border_width)
	node.queue_redraw()

func start_explosion_timer(node: Node2D) -> void:
	var timer_line: Node2D = load("res://fruits/timer_line.tscn").instantiate()
	timer_line.duration = delay
	timer_line.timeout.connect(explode.bind(node))
	timer = timer_line.get_node("Timer")
	node.add_child(timer_line)

func _add_area(node: Node2D, r: float):
	var area: Area2D = Area2D.new()
	area.name = "ExplosiveRadius"
	var collider: CollisionShape2D = CollisionShape2D.new()
	collider.shape = CircleShape2D.new()
	collider.shape.radius = r
	area.add_child(collider)
	node.add_child(area)

func explode(fruit: Node2D):
	var area: Area2D = fruit.get_node("Area2D")
	for a in area.get_overlapping_areas():
		var enemy = a.get_parent()
		if enemy.is_in_group("enemies"):
			# we have to remove the pathFollow that is the parent of enemy
			enemy.get_parent().queue_free()		
	ExplosionBus.exploded.emit(fruit)
