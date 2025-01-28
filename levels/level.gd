extends Node2D
class_name Level

signal health_depleted
signal level_completed

@export var waves: Array[Wave]
@export var health: int

@onready var play_area: ColorRect = $PlayArea
@onready var fruit_list = $FruitList
@onready var waves_container = $WavesContainer
@onready var health_count = $Health/Count
@onready var wave_no = $WaveNo

var active_fruit: Node2D
var active_fruit_name = "apple"
var resolving = false
var dragging_fruits = []
var curr_wave_idx = 0
var showing_tutorial = true
var enemies_count = 0

func curr_wave() -> Wave:
	return waves[curr_wave_idx]

func _ready() -> void:
	# create fruits HUD
	Fruits.create_fruit_list_hud($FruitList)
	Fruits.fruit_selected.connect(_on_fruit_list_selected)
	
	# add tutorial
	var tutorial = load("res://levels/tutorial.tscn").instantiate()
	tutorial.closed.connect(_on_tutorial_closed)
	self.add_child(tutorial)
	
	# we are finding out when a levels is completed if all enemies in wave are either exploded
	# or done damage to us
	ExplosionBus.exploded.connect(func(f,e): enemies_count += e)
	
	level_completed.connect(on_level_completed)
	health_depleted.connect(on_health_depleted)
	
	WaveHistory.add_wave(curr_wave_idx, health, Fruits.ammo)
	WaveHistory.level_change.connect(_on_level_change)
	update_wave_label()
	
func _process(delta: float) -> void:
	if resolving and enemies_count == curr_wave().convoys.reduce(func(acc,v): return acc + v.count ,0):
		if len(waves) == curr_wave_idx + 1:
			level_completed.emit()
			return
		else:
			print("wave passed")
			WaveHistory.add_wave(curr_wave_idx + 1, health, Fruits.ammo)
			resolving = false
			curr_wave_idx += 1
			enemies_count = 0
			print("wave completed")
			create_wave(true)

func _on_tutorial_closed():
	showing_tutorial = false
	create_wave(true)

func _input(event: InputEvent) -> void:
	var menu = self.get_node("Menu")
	if event.is_action_pressed("Menu"):
		if not is_instance_valid(menu):
			menu = load("res://menu/in_game_menu.tscn").instantiate()
			menu.name = "Menu"
			menu.closed.connect(resume_movement)
			stop_movement()
			self.add_child(menu)
		else:
			self.get_node("Menu").closed.emit()
	if not play_area.get_rect().has_point(get_global_mouse_position()):
		return
	if Input.is_key_pressed(KEY_CTRL) and is_instance_valid(active_fruit):
		active_fruit.queue_free()
	if not Input.is_key_pressed(KEY_CTRL) and not is_instance_valid(active_fruit) and not showing_tutorial:
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
	curr_wave().is_preview = false
	create_wave(false)

# we are adding the active_fruit when the mouse enters the play area
func _on_play_area_mouse_entered() -> void:
	if not is_instance_valid(active_fruit) and not resolving and not showing_tutorial and Fruits.can_place_fruit(active_fruit_name):
		active_fruit = Fruits.create_fruit(active_fruit_name)
		active_fruit.modulate.a = 0.3
		active_fruit.position = get_global_mouse_position()
		self.add_child(active_fruit)

# we are removing the active_fruit when the mouse leaves the play area
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
		if not is_instance_valid(active_fruit):
			return
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


func create_wave(preview: bool):
	update_wave_label()
	clear_wave()
	print("create wave ", curr_wave_idx)
	var wave = curr_wave()
	wave.is_preview = preview
	for c in wave.convoys:
		var river_node = c.river.instantiate()
		var river = river_node.get_node("Path2D")
		var t = Timer.new()
		t.name = "Timer"
		t.wait_time = c.spawn_interval
		t.one_shot = false
		t.autostart = true
		t.timeout.connect(func(): add_enemy(c, river, t))
		river_node.add_child(t)
		waves_container.add_child(river_node)
	
func add_enemy(convoy: Convoy, path: Path2D, timer: Timer):
	if path.get_child_count() >= convoy.count:
		timer.stop()
		return
	var pf = PathFollow2D.new()
	pf.set_script(load("res://waves/rivers/_river.gd"))
	pf.speed = convoy.speed
	var enemy = convoy.enemy.instantiate()
	if curr_wave().is_preview:
		enemy.get_node("Sprite2D").modulate.a = 0.5
		var collision_shape: CollisionShape2D = 	enemy.get_node("Area2D").get_node("CollisionShape2D")
		collision_shape.disabled = true
	else:
		pf.enemy_passed.connect(enemy_passed)
		pf.loop = false
	pf.add_child(enemy)
	path.add_child(pf)

func enemy_passed():
	enemies_count += 1
	var count = int(health_count.text)
	if count > 0:
		count -= 1
		health -= 1
		health_count.text = str(count)
	if count == 0:
		health_depleted.emit()

func on_level_completed():
	print("level completed!")
	var level_won = load("res://level_won.tscn").instantiate()
	level_won.score = Utils.calc_score(health, Fruits.ammo)
	SceneManager.change_scene.emit(level_won)

func on_health_depleted():
	var menu: Node2D = load("res://menu/in_game_menu.tscn").instantiate()
	menu.name = "Menu"
	menu.get_node("ColorRect").get_node("CloseMenu").queue_free()
	clear_wave()
	self.add_child(menu)

func stop_movement():
	var paths = get_tree().get_nodes_in_group("paths")
	for p in paths:
		var t: Timer = p.get_parent().get_node("Timer")
		t.stop()
		for pf in p.get_children():
			if pf is PathFollow2D:
				pf.paused = true

func resume_movement():
	var paths = get_tree().get_nodes_in_group("paths")
	for p in paths:
		var t: Timer = p.get_parent().get_node("Timer")
		t.start()
		for pf in p.get_children():
			if pf is PathFollow2D:
				pf.paused = false

func clear_wave():
	for c in waves_container.get_children():
		c.queue_free()

func _on_level_change(idx: int, hp: int):
	self.get_node("Menu").closed.emit()
	clear_wave()
	health = hp
	health_count.text = str(hp)
	curr_wave_idx = idx
	resolving = false
	enemies_count = 0
	for c in $FruitList.get_children():
		c.queue_free()
	for c in get_tree().get_nodes_in_group("fruits"):
		if c.explosive:
			c.queue_free()
	Fruits.create_fruit_list_hud($FruitList)
	create_wave(true)
	
func update_wave_label():
	wave_no.text = "Wave \n %s - %s" % [self.get_parent().name, curr_wave_idx + 1]
