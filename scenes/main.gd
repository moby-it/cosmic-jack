extends Node2D

@onready var apple_scn = preload("res://entities/fruits/apple.tscn")
@onready var watermelon_scn = preload("res://entities/fruits/watermelon.tscn")
@onready var play_area = $play_area
@onready var choreography = $Choreography
var resolving = false
var active_fruit_scn
enum FRUITS { APPLE = 0, WATERMELON }
var active_fruit = FRUITS.APPLE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	active_fruit_scn = apple_scn.instantiate()
	active_fruit_scn.modulate.a = 0.3
	self.add_child(active_fruit_scn)


func _input(event) -> void:
	if(event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && active_fruit_scn && play_area.get_rect().has_point(event.position)):
		place_fruit(event.position)
	if (event is InputEventMouseMotion && is_instance_valid(active_fruit_scn) && play_area.get_rect().has_point(event.position)):
		active_fruit_scn.position = event.position

func place_fruit(position: Vector2) -> void:
	var scn = create_fruit_scn()
	scn.position = Vector2(position)
	self.add_child(scn)

func create_fruit_scn() -> Node:
	var scn
	match active_fruit:
		0:
			scn =  apple_scn.instantiate()
		1: 
			scn =  watermelon_scn.instantiate()
	return scn

func _on_hud_fruit_selected(f: int) -> void:
	active_fruit = f

func _on_play_area_mouse_entered() -> void:
	if not is_instance_valid(active_fruit_scn) && not resolving:
		active_fruit_scn = create_fruit_scn()
		active_fruit_scn.modulate.a = 0.3
		self.add_child(active_fruit_scn)

func _on_play_area_mouse_exited() -> void:
	if is_instance_valid(active_fruit_scn):
		active_fruit_scn.queue_free()


func _on_resolve_resolve_wave() -> void:
	resolving = true
	choreography.attributes.is_preview = false
	choreography.start_timer()
	var enemy_path= choreography.get_node("EnemyPath2D")
	enemy_path.curr_enemies = 0
	for n in enemy_path.get_children():
		n.queue_free()
