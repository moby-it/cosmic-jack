extends Node2D
class_name Level

signal health_depleted
signal level_completed

enum ROUND_STATUS {
	PREVIEW,
	RESOLVING,
	RESOLVED
}

var round_status = ROUND_STATUS.PREVIEW
# used for pausing
var audio_position = 0.0
func resolving():
	return round_status == ROUND_STATUS.RESOLVING

@export var waves: Array[Wave]
var active_waves: Array[Wave]
@export var health = 3 

@onready var play_area: ColorRect = $PlayArea
@onready var fruit_list = $FruitList
@onready var waves_container = $WavesContainer
@onready var health_count = $Health/HBoxContainer/Count
@onready var wave_no = $WaveNo
@onready var wave_audio: AudioStreamPlayer = $WaveAudio

var beat_fns = []

var active_fruit: Node2D
var active_fruit_name = "apple"
var dragging_fruits = []
var curr_wave_idx = 0
var resolving_progres = 0

func curr_wave() -> Wave:
	return active_waves[curr_wave_idx]

func _ready() -> void:
	active_waves = waves.filter(func(w): return w.enabled)
	level_completed.connect(on_level_completed)
	health_depleted.connect(on_health_depleted)
	
	WaveHistory.add_wave(curr_wave_idx, health)
	WaveHistory.level_change.connect(_on_level_change)
	update_wave_label()
	health_count.text = str(health)
	create_wave(true)
	
func _process(_delta: float) -> void:
	#print("all convoys rendered %s" % all_convoys_rendered())
	#print("rendered_pfs_count %s" % rendered_pfs_count())
	if health <= 0:
		return
	match round_status:
		ROUND_STATUS.RESOLVED:
			if len(active_waves) == curr_wave_idx + 1:
				level_completed.emit()
				return
			else:
				print("wave passed")
				WaveHistory.add_wave(curr_wave_idx + 1, health)
				curr_wave_idx += 1
				print("wave completed")
				create_wave(true)
		ROUND_STATUS.RESOLVING:
			if all_convoys_rendered() and rendered_pfs_count() == 0:
				round_status = ROUND_STATUS.RESOLVED

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Menu"):
		var menu = self.get_node_or_null("Menu")
		if is_instance_valid(menu):
			menu.closed.emit()
		else:
			# add menu
			menu = load("res://menu/in_game_menu.tscn").instantiate()
			menu.name = "Menu"
			menu.closed.connect(resume_movement)
			stop_movement()
			self.add_child(menu)
	if not play_area.get_rect().has_point(get_global_mouse_position()):
		return
	if Input.is_key_pressed(KEY_CTRL) and is_instance_valid(active_fruit):
		active_fruit.queue_free()
	if not Input.is_key_pressed(KEY_CTRL) and not is_instance_valid(active_fruit):
		add_active_fruit()

func on_fruit_list_selected(i: String) -> void:
	active_fruit_name = i

func add_active_fruit():
	if not is_instance_valid(active_fruit) && not resolving():
		active_fruit = Fruits.create_fruit(active_fruit_name)
		active_fruit.modulate.a = 0.3
		active_fruit.position = get_global_mouse_position()
		self.add_child(active_fruit)

func _on_resolve_button_down() -> void:
	if not resolving():
		round_status = ROUND_STATUS.RESOLVING
		create_wave(false)

# we are adding the active_fruit when the mouse enters the play area
func _on_play_area_mouse_entered() -> void:
	if not is_instance_valid(active_fruit) and not resolving and Fruits.can_place_fruit(active_fruit_name):
		active_fruit = Fruits.create_fruit(active_fruit_name)
		active_fruit.modulate.a = 0.3
		active_fruit.position = get_global_mouse_position()
		self.add_child(active_fruit)

# we are removing the active_fruit when the mouse leaves the play area
func _on_play_area_mouse_exited() -> void:
	if is_instance_valid(active_fruit):
		active_fruit.queue_free()


func _on_play_area_gui_input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_CTRL) and not resolving():
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

func place_fruit(p: Vector2) -> void:
	if not Fruits.can_place_fruit(active_fruit_name):
		return
	var node = Fruits.create_fruit(active_fruit_name)
	node.position = Vector2(p)
	self.add_child(node)
	# if you cannot place any more fruits of the same stack, we remove the active fruit element
	Fruits.reduce_fruit_ammo(active_fruit_name)
	if not Fruits.can_place_fruit(active_fruit_name):
		active_fruit.queue_free()


func create_wave(preview: bool):
	var wave = curr_wave()

	update_wave_label()
	clear_wave()
		# create fruits HUD
	if preview:
		for c in $FruitList.get_children():
			c.queue_free()
		Fruits.create_fruit_list_hud($FruitList, wave)
		Fruits.fruit_selected.connect(on_fruit_list_selected)
	
	print("create wave %s, preview %s" % [curr_wave_idx, preview])
	print("create wave %s, preview %s" % [curr_wave_idx, preview])
	round_status = ROUND_STATUS.PREVIEW if preview else ROUND_STATUS.RESOLVING
	wave_audio.stream = load(wave.audio_track)
	BpmManager.bpm = wave.bpm
	BpmManager.seconds_per_beat = 60.0 / wave.bpm
	BpmManager.time_begin = Time.get_ticks_usec()
	BpmManager.time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	print("delay %s" % BpmManager.time_delay)
	print("wave bpm %s" % wave.bpm)
	BpmManager.seconds_per_beat = 60.0 / wave.bpm
	wave_audio.play()

	for c in wave.convoys:
		ExplosionBus.enemies_exploded[c.get_instance_id()] = 0
		var river_node = c.river.instantiate()
		var river = river_node.get_node("Path2D")
		var beat_fn = func(i: int): 
			if c.rendered: 
				return
			var duration = largest_duration()
			var remainder = i % duration if i >= duration else i
			if remainder < c.count:
				return add_enemy_preview(c, river) if preview else add_enemy_resolve(c,river)
		beat_fns.push_back(beat_fn)
		BpmManager.on_beat.connect(beat_fn)
		waves_container.add_child(river_node)
	
func add_enemy_resolve(convoy: Convoy, path: Path2D):
	print("path child count %s" % path.get_child_count())
	print("rendered %s" % convoy.rendered)
	var pf = PathFollow2D.new()
	pf.set_script(load("res://waves/rivers/_river.gd"))
	pf.duration = convoy.duration
	var enemy: Node2D = convoy.enemy.instantiate()
	enemy.queue_animation = true
	enemy.convoy_id =  convoy.get_instance_id()
	pf.enemy_passed.connect(enemy_passed)
	pf.add_child(enemy)
	path.add_child(pf)
	if path.get_child_count() == convoy.count:
		convoy.rendered = true

func add_enemy_preview(convoy: Convoy, path: Path2D):
	var pf = PathFollow2D.new()
	pf.set_script(load("res://waves/rivers/_river.gd"))
	pf.duration = convoy.duration
	var enemy: Node2D = convoy.enemy.instantiate()
	enemy.queue_animation = true
	enemy.convoy_id =  convoy.get_instance_id()
	enemy.collision = false
	pf.add_child(enemy)
	path.add_child(pf)

func enemy_passed():
	if health > 0:
		health -= 1
		health_count.text = str(health)
	if health == 0:
		health_depleted.emit()

func on_level_completed():
	print("level completed!")
	BpmManager.reset()
	var level_won = load("res://level_won.tscn").instantiate()
	SceneManager.change_scene.emit(level_won)

func on_health_depleted():
	var menu: Node2D = load("res://menu/in_game_menu.tscn").instantiate()
	menu.name = "Menu"
	menu.get_node("ColorRect").get_node("CloseMenu").queue_free()
	clear_wave()
	self.add_child(menu)

func stop_movement():
	audio_position = wave_audio.get_playback_position()
	wave_audio.stop()
	BpmManager.bpm = 0
	var paths = get_tree().get_nodes_in_group("paths")
	for p in paths:
		for pf in p.get_children():
			if pf is PathFollow2D:
				pf.paused = true

func resume_movement():
	var paths = get_tree().get_nodes_in_group("paths")
	var wave = curr_wave()
	for p in paths:
		for pf in p.get_children():
			if pf is PathFollow2D:
				pf.paused = false
	BpmManager.bpm = wave.bpm
	wave_audio.play(audio_position)
	audio_position = 0.0

func _on_level_change(idx: int, hp: int):
	self.get_node("Menu").closed.emit()
	clear_wave()
	health = hp
	health_count.text = str(hp)
	curr_wave_idx = idx
	create_wave(true)
	
func clear_wave():
	for c in waves_container.get_children():
		c.queue_free()
		for f in beat_fns:
			BpmManager.on_beat.disconnect(f)
		beat_fns.clear()
	BpmManager.reset()
	ExplosionBus.enemies_exploded = {}

func update_wave_label():
	wave_no.text = "Wave \n %s - %s" % [self.get_parent().name, curr_wave_idx + 1]

func rendered_pfs_count() -> int:
	return waves_container.get_children().reduce(func(acc, c): return acc + c.get_node("Path2D").get_child_count(), 0)

func largest_duration() -> int:
	return curr_wave().convoys.map(func(c): return c.duration).max()
	
func all_convoys_rendered() -> bool:
	return curr_wave().convoys.all(func(c): return c.rendered)
