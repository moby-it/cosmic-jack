extends Node2D
class_name Level

@export var level_index: int = 1
@export var waves: Array[Wave]
var active_waves: Array[Wave]

@export_subgroup("Audio")
@export_file("*.wav", "*.mp3") var audio_track: String
@export var bpm = 0

@onready var play_area: ColorRect = $PlayArea
@onready var fruit_list: VBoxContainer = $FruitList
@onready var waves_container = $WavesContainer
@onready var wave_no = $WaveNo
@onready var wave_audio: AudioStreamPlayer = $WaveAudio

# Wave Announcer Control
var wave_announcer
var beat_fns = []
var dragging_fruit: Node2D
var curr_wave_idx = 0

func curr_wave() -> Wave:
	return active_waves[curr_wave_idx]

func _ready() -> void:
	active_waves = waves.filter(func(w): return w.enabled)
	LevelState.level_completed.connect(on_level_completed)
	LevelState.wave_completed.connect(on_wave_completed)
	Fruits.fruit_selected.connect(add_dragging_fruit)
	update_wave_label()
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
	if event.is_action_pressed("Restart"):
		restart_wave()
	if event is InputEventMouseMotion and is_instance_valid(dragging_fruit):
		dragging_fruit.position = get_global_mouse_position()
	elif Utils.is_mouse_left_up(event) and dragging_fruit:
		if play_area.get_rect().has_point(get_global_mouse_position()):
			var f = place_fruit(dragging_fruit, get_global_mouse_position())
			LevelState.edit_fruit_placed(f)
			gray_out_fruit(f)
		else:
			remove_fruit(dragging_fruit)
	elif Utils.is_mouse_left_down(event) and not is_instance_valid(dragging_fruit):
		var f = Fruits.find_fruits_under_cursor()
		if f.is_empty():
			return
		if not f[0].exploding:
			dragging_fruit = f[0]
			LevelState.disable_fruit_collision(dragging_fruit)
			

func gray_out_fruit(fruit: Node2D):
	for i in fruit_list.get_child_count():
		var f = fruit_list.get_child(i)
		if f.get_meta("name") == fruit.get_meta("name"):
			var hud_node = f.get_child(fruit.get_meta("hud_idx"))
			hud_node.material = ShaderMaterial.new()
			hud_node.material.shader = load("res://fruits/grayscale.gdshader")

func ungray_out_fruit(fruit: Node2D):
	for i in fruit_list.get_child_count():
		var f = fruit_list.get_child(i)
		if f.get_meta("name") == fruit.get_meta("name"):
			var hud_node = f.get_child(fruit.get_meta("hud_idx"))
			hud_node.material = null

func remove_fruit(fruit: Node2D):
		ungray_out_fruit(fruit)
		LevelState.remove_fruit_placed(dragging_fruit)
		dragging_fruit.queue_free()
		dragging_fruit = null

func add_dragging_fruit(name: String, idx: int):
	dragging_fruit = Fruits.create_fruit(name)
	dragging_fruit.set_meta("hud_idx", idx)
	dragging_fruit.modulate.a = 0.3
	dragging_fruit.position = get_global_mouse_position()
	LevelState.disable_fruit_collision(dragging_fruit)
	# should disable collisions
	self.add_child(dragging_fruit)

func place_fruit(fruit: Node2D, p: Vector2) -> Node2D:
	#print("placing fruit")
	fruit.position = Vector2(p)
	fruit.modulate.a = 1
	fruit.add_to_group("fruits")
	LevelState.enable_fruit_collision(fruit)
	dragging_fruit = null
	return fruit

func create_fruit_list(wave: Wave):
	clear_fruit_hud()
	Fruits.create_fruit_list_hud($FruitList, wave)
	
func create_wave(wave: Wave):
	update_wave_label()
	
	print("create wave %s" % [curr_wave_idx])
	# Wire up wave completion checker
	var wave_completed_fn = func(_i: int):
		# If all enemies have been spawned and none are left on the screen, the wave is completed
		if LevelState.wave_enemies_exploded(curr_wave()):
			LevelState.wave_completed.emit()
			return
		if LevelState.all_convoys_rendered(curr_wave()) and rendered_pfs_count() == 0:
			restart_wave()
	AudioManager.on_beat.connect(wave_completed_fn)
	beat_fns.push_back(wave_completed_fn)
	
	render_convoys(wave)

func render_convoys(wave: Wave):
	var duration = LevelState.largest_convoy_duration(curr_wave())
	var offset = AudioManager.beat % duration if AudioManager.beat >= duration else AudioManager.beat
	print("wave offset %s" % offset)
	for c in wave.convoys:
		c.rendered = false
		LevelState.enemies_exploded[c.get_instance_id()] = 0
		var river_node = c.river.instantiate()
		var river = river_node.get_node("Path2D")
		
		var beat_fn = convoy_beat_fn(c, river, offset)
		beat_fns.push_back(beat_fn)
		AudioManager.on_beat.connect(beat_fn)
		waves_container.add_child(river_node)

func convoy_beat_fn(c: Convoy, river: Path2D, offset: int):
	var duration = LevelState.largest_convoy_duration(curr_wave())
	return func(i: int):
		if c.rendered:
			return
		var remainder = (i - offset - 1) % duration if i >= offset else i
		#print("beat %s" % i)
		#print("remainder %s" % remainder)
		#print("count %s" % c.count)
		#print("delay %s" % c.delay)
		var adjusted_remainder = remainder - c.delay
		if adjusted_remainder >= 0 and adjusted_remainder < c.count:
			#print("adding enemy")
			return add_enemy(c,river)

func add_enemy(convoy: Convoy, path: Path2D):
	var pf = PathFollow2D.new()
	pf.set_script(load("res://waves/rivers/_river.gd"))
	pf.duration = convoy.duration
	var enemy: Node2D = convoy.enemy.instantiate()
	enemy.queue_animation = true
	enemy.set_meta("convoy_id", convoy.get_instance_id())
	pf.add_child(enemy)
	path.add_child(pf)
	if path.get_child_count() + LevelState.enemies_exploded[convoy.get_instance_id()] == convoy.count:
		convoy.rendered = true
	#print("path child count %s" % path.get_child_count())
	#print("rendered %s" % convoy.rendered)

func restart_wave():
	# Restart the level when an enemy passes
	clear_wave()
	clear_fruits()
	re_place_fruits(LevelState.fruits_placed)
	create_wave(curr_wave())

func re_place_fruits(fruits: Dictionary):
	LevelState.fruits_placed = {}
	for f_id in fruits:
		var f = fruits[f_id]
		self.add_child(place_fruit(f, f.position))
		LevelState.edit_fruit_placed(f)

func on_level_completed():
	print("level completed!")
	AudioManager.reset()
	var level_won = load("res://level_won.tscn").instantiate()
	SceneManager.change_scene.emit(level_won)
	
func on_wave_completed():
	if len(active_waves) == curr_wave_idx + 1:
		LevelState.level_completed.emit()
		return
	LevelState.fruits_placed = {}
	print("wave passed")
	curr_wave_idx += 1
	clear_wave()
	clear_fruits()
	show_announcer()

func _on_level_change(idx: int, hp: int):
	if is_instance_valid(wave_announcer):
		wave_announcer.queue_free()
	var menu = self.get_node_or_null("Menu")
	if menu:
		menu.closed.emit()
	clear_wave()
	curr_wave_idx = idx
	show_announcer()

## clears enemies enemies from screen, and associated structures
func clear_wave():
	for c in waves_container.get_children():
		c.queue_free()
	for f in beat_fns:
		AudioManager.on_beat.disconnect(f)
	beat_fns.clear()
	LevelState.enemies_exploded = {}

## removes all fruits from the play area
func clear_fruits():
	var fruits = self.get_tree().get_nodes_in_group("fruits")
	for f in fruits:
		f.queue_free()

func clear_fruit_hud():
	for c in $FruitList.get_children():
		c.queue_free()

func update_wave_label():
	wave_no.text = "%s - %s" % [level_index, curr_wave_idx + 1]

func rendered_pfs_count() -> int:
	return waves_container.get_children().reduce(func(acc, c): return acc + c.get_node("Path2D").get_child_count(), 0)

func show_announcer():
	if is_instance_valid(wave_announcer):
		return
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
	create_fruit_list(curr_wave())

func _on_wave_announcer_gui_input(event: InputEvent) -> void:
	if Utils.is_mouse_left_down(event):
		await hide_announcer()
		create_wave(curr_wave())

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
