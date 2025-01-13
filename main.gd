extends Node2D

@onready var play_area = $play_area
@onready var choreography = $Choreography
@onready var fruit_list = $FruitList
var resolving = false

var active_fruit: Node2D
var active_fruit_name = "apple"

func _ready() -> void:
	SelectedFruits.create_fruit_list_hud($FruitList)
	SelectedFruits.fruit_selected.connect(_on_fruit_list_selected)

func is_mouse_left(event) -> bool:
	return event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.is_pressed()
func is_mouse_right(event) -> bool:
	return event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_RIGHT && event.is_pressed()
func is_mouse_move(event) -> bool:
	return event is InputEventMouseMotion && is_instance_valid(active_fruit)	

func place_fruit(position: Vector2) -> void:
	if not SelectedFruits.can_place_fruit(active_fruit_name):
		return
	var node = create_fruit()
	node.position = Vector2(position)
	self.add_child(node)
	# if you cannot place any more fruits of the same stack, we remove the active fruit element
	SelectedFruits.reduce_fruit_ammo(active_fruit_name)
	if not SelectedFruits.can_place_fruit(active_fruit_name):
		active_fruit.queue_free()

func create_fruit() -> Node2D:
	var fruit: Node2D = SelectedFruits.available_fruits[active_fruit_name].instantiate()
	fruit.explosive.draw_explosive_radius(fruit)
	return fruit

func _on_play_area_mouse_entered() -> void:
	if not is_instance_valid(active_fruit) && not resolving and SelectedFruits.can_place_fruit(active_fruit_name):
		active_fruit = create_fruit()
		active_fruit.modulate.a = 0.3
		active_fruit.position = get_global_mouse_position()
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

func _on_fruit_list_selected(i: String) -> void:
	active_fruit_name = i

func add_active_fruit():
	if not is_instance_valid(active_fruit) && not resolving:
		active_fruit = create_fruit()
		active_fruit.modulate.a = 0.3
		active_fruit.position = get_global_mouse_position()
		self.add_child(active_fruit)
	
func _on_play_area_gui_input(event: InputEvent) -> void:
	if is_mouse_left(event):
		place_fruit(get_global_mouse_position())
	elif is_mouse_move(event):
		active_fruit.position = get_global_mouse_position()
