extends Node2D
class_name Level

@export var waves: Array[Wave]
@export var health: int

@onready var play_area: ColorRect= $PlayArea
@onready var fruit_list = $FruitList
@onready var waves_container = $WavesContainer

var active_fruit: Node2D
var active_fruit_name = "apple"
var resolving = false
var dragging_fruits = []
var curr_wave_idx = 0

func _ready() -> void:
	Fruits.create_fruit_list_hud($FruitList)
	Fruits.fruit_selected.connect(_on_fruit_list_selected)

func _input(event: InputEvent) -> void:
	if not play_area.get_rect().has_point(get_global_mouse_position()):
		return
	if Input.is_key_pressed(KEY_CTRL) and is_instance_valid(active_fruit):
		active_fruit.queue_free()
	if not Input.is_key_pressed(KEY_CTRL) and not is_instance_valid(active_fruit):
		add_active_fruit()

func _on_fruit_list_selected(i: String) -> void:
	active_fruit_name = i

func add_active_fruit():
	if not is_instance_valid(active_fruit) && not resolving:
		active_fruit = Fruits.create_fruit(active_fruit_name)
		active_fruit.modulate.a = 0.3
		active_fruit.position = get_global_mouse_position()
		self.add_child(active_fruit)

func _on_resolve_button_down() -> void:
	resolving = true
	var wave: Wave = waves[curr_wave_idx]
	wave.is_preview = false
	for c in waves_container.get_children():
		c.queue_free()
	create_wave(true)

func _on_play_area_mouse_entered() -> void:
	if not is_instance_valid(active_fruit) && not resolving and Fruits.can_place_fruit(active_fruit_name):
		active_fruit = Fruits.create_fruit(active_fruit_name)
		active_fruit.modulate.a = 0.3
		active_fruit.position = get_global_mouse_position()
		self.add_child(active_fruit)

func _on_play_area_mouse_exited() -> void:
	if is_instance_valid(active_fruit):
		active_fruit.queue_free()


func _on_play_area_gui_input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_CTRL):
		if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				dragging_fruits = Fruits.find_fruits_under_cursor()
			else:
				dragging_fruits = []
		elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			if len(dragging_fruits) > 0:
				for df in dragging_fruits:
					df.position = get_global_mouse_position()
		elif Utils.is_mouse_right(event):
			var fruits = Fruits.find_fruits_under_cursor()
			if len(fruits): 
				for f in fruits:
					Fruits.add_fruit_ammo(f.get_meta("name"))
					f.queue_free()
	else:
		if Utils.is_mouse_left(event):
			place_fruit(get_global_mouse_position())
		elif Utils.is_mouse_move(event):
			active_fruit.position = get_global_mouse_position()

func place_fruit(position: Vector2) -> void:
	if not Fruits.can_place_fruit(active_fruit_name):
		return
	var node = Fruits.create_fruit(active_fruit_name)
	node.position = Vector2(position)
	self.add_child(node)
	# if you cannot place any more fruits of the same stack, we remove the active fruit element
	Fruits.reduce_fruit_ammo(active_fruit_name)
	if not Fruits.can_place_fruit(active_fruit_name):
		active_fruit.queue_free()


# TODO 
# 1. should create wave on level init in preview mode.
# 2. should be able to resolve wave
# 3. after the wave has ended increment idx and render next wave
# 4. track hp, and game end
func create_wave(preview: bool):
	pass
	#var wave: Wave = waves[curr_wave_idx]
	#wave.is_preview = preview
	#for c in wave.convoys:
		#var p = c.path.instantiate()
		#var t = Timer.new()
		#t.wait_time = c.spawn_interval
		#t
	#var river: River = PathFollow2D.new()
	#river.set_script(load("res://waves/rivers/_river.gd"))
	#river.enemy_passed.connect(func() :print("enemy passed"))
	
