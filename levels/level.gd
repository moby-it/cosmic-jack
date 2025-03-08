extends Node2D
class_name Level

signal health_depleted
signal level_completed
signal wave_completed
signal fruit_placed

var control_tooltips = "ctrl + left_click = move fruit, ctrl + right click = remove fruit, r = restart wave preview"

enum ROUND_STATUS {
	PREVIEW,
	RESOLVING,
	RESOLVED
}

var round_status = ROUND_STATUS.PREVIEW

func resolving():
	return round_status == ROUND_STATUS.RESOLVING
	
func preview():
	return round_status == ROUND_STATUS.PREVIEW

func set_preview():
	round_status = ROUND_STATUS.PREVIEW
	resolve_btn.disabled = false
	resolve_btn.text = "resolve wave"

# used for pausing
var audio_position = 0.0
var health = 1
@export var level_index: int = 1
@export var waves: Array[Wave]
var active_waves: Array[Wave]

@export_subgroup("Audio")
@export_file("*.wav", "*.mp3") var audio_track: String
@export var bpm = 0

@onready var play_area: ColorRect = $PlayArea
@onready var fruit_list: VBoxContainer = $FruitList
@onready var waves_container = $WavesContainer
@onready var health_count = $Health/HBoxContainer/Count
@onready var wave_no = $WaveNo
@onready var resolve_btn:Button = $Resolve

# Wave Announcer Control
var wave_announcer

@onready var wave_audio: AudioStreamPlayer = $WaveAudio

var beat_fns = []

var active_fruit: Node2D
var active_fruit_name: String = ""
var dragging_fruits = []
var curr_wave_idx = 0
var resolving_progres = 0

func curr_wave() -> Wave:
	return active_waves[curr_wave_idx]

func _ready() -> void:
	active_waves = waves.filter(func(w): return w.enabled)
	level_completed.connect(on_level_completed)
	wave_completed.connect(on_wave_completed)
	health_depleted.connect(on_health_depleted)
	WaveHistory.level_index = level_index
	WaveHistory.add_wave(curr_wave_idx, health, curr_wave())
	WaveHistory.level_change.connect(_on_level_change)
	update_wave_label()
	health_count.text = str(health)
	show_announcer()
	start_audio()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Menu"):
		var menu = self.get_node_or_null("Menu")
		if is_instance_valid(menu):
			menu.closed.emit()
		else:
			menu = load("res://menu/in_game_menu.tscn").instantiate()
			menu.name = "Menu"
			self.add_child(menu)
	if not play_area.get_rect().has_point(get_global_mouse_position()):
		return
	if Input.is_key_pressed(KEY_CTRL) and is_instance_valid(active_fruit):
		active_fruit.queue_free()
	if not Input.is_key_pressed(KEY_CTRL) and not is_instance_valid(active_fruit) and not is_instance_valid(wave_announcer):
		add_active_fruit()
	if event.is_action_pressed("Restart") and preview():
		clear_wave()
		render_convoys(curr_wave())

func on_fruit_list_selected(fruit_name: String) -> void:
	active_fruit_name = fruit_name
	render_active_fruit_ui()

func render_active_fruit_ui():
	for c: HBoxContainer in fruit_list.get_children():
		if c.name != active_fruit_name:
			c.get_node("texture").material = ShaderMaterial.new()
			c.get_node("texture").material.shader = load("res://fruits/grayscale.gdshader")
		else:
			c.get_node("texture").material = null

func add_active_fruit():
	if not is_instance_valid(active_fruit) && not resolving() and active_fruit_name:
		active_fruit = Fruits.create_fruit(active_fruit_name)
		active_fruit.modulate.a = 0.3
		active_fruit.position = get_global_mouse_position()
		self.add_child(active_fruit)

func _on_resolve_button_down() -> void:
	print("resolve btn down")
	if not resolving():
		round_status = ROUND_STATUS.RESOLVING
		resolve_btn.disabled = true
		resolve_btn.text = "resolving"
		clear_wave()
		create_wave()

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
	fruit_placed.emit(node)
	# if you cannot place any more fruits of the same stack, we remove the active fruit element
	Fruits.reduce_fruit_ammo(active_fruit_name)
	if not Fruits.can_place_fruit(active_fruit_name):
		active_fruit.queue_free()

func create_fruit_list(wave: Wave):
	clear_fruit_hud()
	Fruits.create_fruit_list_hud($FruitList, wave)
	Fruits.fruit_selected.connect(on_fruit_list_selected)

func select_first_fruit(wave: Wave):
	on_fruit_list_selected(Fruits.find_first_fruit_with_ammo(wave))
		
func create_wave():
	var wave = curr_wave()
	update_wave_label()
	if preview():
		create_fruit_list(wave)
		select_first_fruit(wave)
	
	print("create wave %s, preview %s" % [curr_wave_idx, preview()])

	# wire up wave completed for non preview
	if not preview():
		var wave_completed_fn = func(_i: int):
			if not resolving():
				return
			if all_convoys_rendered() and rendered_pfs_count() == 0 and health > 0:
				wave_completed.emit()
		AudioManager.on_beat.connect(wave_completed_fn)
		beat_fns.push_back(wave_completed_fn)
	
	render_convoys(wave)

func render_convoys(wave: Wave):
	var duration = largest_duration()
	var offset = AudioManager.beat % duration if AudioManager.beat >= duration else AudioManager.beat
	print("wave offset %s" % offset)
	for c in wave.convoys:
		c.rendered = false
		ExplosionBus.enemies_exploded[c.get_instance_id()] = 0
		var river_node = c.river.instantiate()
		var river = river_node.get_node("Path2D")
		
		var beat_fn = convoy_beat_fn(c, river, offset)
		beat_fns.push_back(beat_fn)
		AudioManager.on_beat.connect(beat_fn)
		waves_container.add_child(river_node)

func convoy_beat_fn(c: Convoy, river: Path2D, offset: int):
	var duration = largest_duration()
	return func(i: int):
		if c.rendered:
			return
		var remainder = (i - offset) % duration if i >= offset else i
		#print("beat %s" % i)
		#print("remainder %s" % remainder)
		#print("count %s" % c.count)
		#print("delay %s" % c.delay)
		var adjusted_remainder = remainder - c.delay
		if adjusted_remainder >= 0 and adjusted_remainder < c.count:
			#print("adding enemy")
			return add_enemy_preview(c, river) if preview() else add_enemy_resolve(c,river)

func add_enemy_resolve(convoy: Convoy, path: Path2D):
	#print("path child count %s" % path.get_child_count())
	#print("rendered %s" % convoy.rendered)
	var pf = PathFollow2D.new()
	pf.set_script(load("res://waves/rivers/_river.gd"))
	pf.duration = convoy.duration
	var enemy: Node2D = convoy.enemy.instantiate()
	enemy.queue_animation = true
	enemy.convoy_id =  convoy.get_instance_id()
	pf.enemy_passed.connect(enemy_passed)
	pf.add_child(enemy)
	path.add_child(pf)
	if path.get_child_count() + ExplosionBus.enemies_exploded[convoy.get_instance_id()] == convoy.count:
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
	AudioManager.reset()
	var level_won = load("res://level_won.tscn").instantiate()
	SceneManager.change_scene.emit(level_won)
	
func on_wave_completed():
	round_status = ROUND_STATUS.RESOLVED
	if len(active_waves) == curr_wave_idx + 1:
		level_completed.emit()
		return
	print("wave passed")
	curr_wave_idx += 1
	WaveHistory.add_wave(curr_wave_idx, health,curr_wave())
	clear_wave()
	show_announcer()

func on_health_depleted():
	var menu = self.get_node_or_null("Menu")
	if is_instance_valid(menu):
		return
	menu = load("res://menu/in_game_menu.tscn").instantiate()
	menu.name = "Menu"
	menu.get_node("ColorRect/MarginContainer/VBoxContainer/Label").text = "Wave Lost!"
	menu.get_node("ColorRect").get_node("CloseMenu").queue_free()
	clear_wave()
	self.add_child(menu)

func _on_level_change(idx: int, hp: int):
	if is_instance_valid(wave_announcer):
		wave_announcer.queue_free()
	var menu = self.get_node_or_null("Menu")
	if menu:
		menu.closed.emit()
	clear_wave()
	
	health = hp
	health_count.text = str(hp)
	curr_wave_idx = idx
	show_announcer()

## clears enemies enemies from screen, and associated structures
func clear_wave():
	for c in waves_container.get_children():
		c.queue_free()
	for f in beat_fns:
		AudioManager.on_beat.disconnect(f)
	beat_fns.clear()
	ExplosionBus.enemies_exploded = {}

## removes all fruits from the play area
func clear_fruits():
	var fruits = self.get_tree().get_nodes_in_group("fruits")
	for f in fruits:
		f.queue_free()

func clear_fruit_hud():
	for c in $FruitList.get_children():
		c.queue_free()
	Fruits.fruit_selected.disconnect(on_fruit_list_selected)

func update_wave_label():
	wave_no.text = "%s - %s" % [level_index, curr_wave_idx + 1]

func rendered_pfs_count() -> int:
	return waves_container.get_children().reduce(func(acc, c): return acc + c.get_node("Path2D").get_child_count(), 0)

func largest_duration() -> int:
	return curr_wave().convoys.map(func(c): return c.duration).max()
	
func all_convoys_rendered() -> bool:
	return curr_wave().convoys.all(func(c): return c.rendered)

func show_announcer():
	if is_instance_valid(wave_announcer):
		return
	if is_instance_valid(active_fruit):
		active_fruit.queue_free()
	resolve_btn.release_focus()
	clear_fruits()
	clear_fruit_hud()
	var wave = curr_wave()
	wave_announcer = load("res://levels/wave_announcer.tscn").instantiate()
	wave_announcer.get_node("VBoxContainer/Title").text = wave.title
	wave_announcer.get_node("VBoxContainer/Subtitle").text = wave.subtitle
	wave_announcer.get_node("VBoxContainer/Description").text = wave.description
	wave_announcer.visible = true
	wave_announcer.modulate.a = 0
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(wave_announcer, "modulate:a", 1.0, 1.0)
	wave_announcer.gui_input.connect(_on_wave_announcer_gui_input)
	self.add_child(wave_announcer)

func hide_announcer():
	if not is_instance_valid(wave_announcer):
		return
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(wave_announcer, "modulate:a", 0.0, 1.0)
	await tween.finished
	if is_instance_valid(wave_announcer):
		wave_announcer.queue_free()
	set_preview()
	active_fruit_name = Fruits.find_first_fruit_with_ammo(curr_wave())
	if play_area.get_rect().has_point(get_global_mouse_position()):
		add_active_fruit()

func _on_wave_announcer_gui_input(event: InputEvent) -> void:
	if Utils.is_mouse_left(event):
		await hide_announcer()
		create_wave()

func start_audio():
	wave_audio.stream = load(audio_track)
	AudioManager.reset()
	AudioManager.bpm = bpm
	AudioManager.seconds_per_beat = 60.0 / bpm
	AudioManager.time_begin = Time.get_ticks_usec()
	AudioManager.time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	print("delay %s" % AudioManager.time_delay)
	print("wave bpm %s" % bpm)
	AudioManager.seconds_per_beat = 60.0 / bpm
	wave_audio.play()
	wave_audio.finished.connect((func(): wave_audio.play()))
