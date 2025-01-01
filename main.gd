extends Node2D

@onready var play_area = $play_area
@onready var choreography = $Choreography
@onready var fruit_list = $FruitList
var resolving = false

enum FRUITS { APPLE = 0, WATERMELON }
var active_fruit_idx = FRUITS.APPLE
var active_fruit: Node2D

func _ready() -> void:
	CircleShape2D
	SelectedFruits.create_fruit_list_hud($FruitList)
	SelectedFruits.fruit_selected.connect(_on_fruit_list_selected)
	active_fruit = create_fruit()
	active_fruit.modulate.a = 0.3
	self.add_child(active_fruit)

func is_mouse_left(event) -> bool:
	return event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.is_pressed() && active_fruit && play_area.get_rect().has_point(event.position)
func is_mouse_move(event) -> bool:
	return event is InputEventMouseMotion && is_instance_valid(active_fruit) && play_area.get_rect().has_point(event.position)	

func _input(event) -> void:
	if is_mouse_left(event):
		place_fruit(event.position)
	elif is_mouse_move(event):
		active_fruit.position = event.position

func place_fruit(position: Vector2) -> void:
	var node = create_fruit()
	node.position = Vector2(position)
	self.add_child(node)

func create_fruit() -> Node2D:
	var fruit: Node2D =  SelectedFruits.available_fruits[active_fruit_idx].instantiate()
	fruit.explosive.draw_explosive_radius(fruit)
	return fruit

func _on_play_area_mouse_entered() -> void:
	if not is_instance_valid(active_fruit) && not resolving:
		active_fruit = create_fruit()
		active_fruit.modulate.a = 0.3
		self.add_child(active_fruit)

func _on_play_area_mouse_exited() -> void:
	if is_instance_valid(active_fruit):
		active_fruit.queue_free()

func _on_resolve_resolve_wave() -> void:
	Health.health = 3
	resolving = true
	choreography.attributes.is_preview = false
	choreography.start_timer()
	var enemy_path= choreography.get_node("EnemyPath2D")
	enemy_path.curr_enemies = 0
	for n in enemy_path.get_children():
		n.queue_free()

func _on_fruit_list_selected(i: int) -> void:
	active_fruit_idx = i
