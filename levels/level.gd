extends Node2D
class_name Level

var control_tooltips = "ctrl + left_click = move fruit, ctrl + right click = remove fruit, r = restart wave preview"

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
	LevelManager.level_completed.connect(on_level_completed)
	LevelManager.wave_completed.connect(on_wave_completed)
	Fruits.fruit_selected.connect(add_dragging_fruit)
	WaveHistory.level_index = level_index
	WaveHistory.add_wave(curr_wave_idx, curr_wave())
	WaveHistory.level_change.connect(_on_level_change)
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
		enemy_passed()
	if event is InputEventMouseMotion and is_instance_valid(dragging_fruit):
		dragging_fruit.position = get_global_mouse_position()
	elif Utils.is_mouse_left_up(event) and dragging_fruit:
		if play_area.get_rect().has_point(get_global_mouse_position()):
			var f = place_fruit(dragging_fruit, get_global_mouse_position())
			LevelManager.edit_fruit_placed(f)
			gray_out_fruit(f)
		else:
			remove_fruit(dragging_fruit)
	elif Utils.is_mouse_left_down(event) and not is_instance_valid(dragging_fruit):
		var f = Fruits.find_fruits_under_cursor()
		if f.is_empty():
			return
		if not f[0].exploding:
			dragging_fruit = f[0]

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
		LevelManager.remove_fruit_placed(dragging_fruit)
		dragging_fruit.queue_free()
		dragging_fruit = null

func add_dragging_fruit(name: String, idx: int):
	dragging_fruit = Fruits.create_fruit(name)
	dragging_fruit.set_meta("hud_idx", idx)
	dragging_fruit.modulate.a = 0.3
	dragging_fruit.position = get_global_mouse_position()
	var area: Area2D = dragging_fruit.get_node("ExplosiveRadius")
	area.monitoring = false
	# should disable collisions
	self.add_child(dragging_fruit)
	


func place_fruit(fruit: Node2D, p: Vector2) -> Node2D:
	fruit.position = Vector2(p)
	fruit.modulate.a = 1
	var area: Area2D = fruit.get_node("ExplosiveRadius")
	area.monitoring = true
	self.add_child(fruit)
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
		if all_convoys_rendered() and rendered_pfs_count() == 0:
			LevelManager.wave_completed.emit()
	AudioManager.on_beat.connect(wave_completed_fn)
	beat_fns.push_back(wave_completed_fn)
	
	render_convoys(wave)

func render_convoys(wave: Wave):
	var duration = largest_duration()
	var offset = AudioManager.beat % duration if AudioManager.beat >= duration else AudioManager.beat
	print("wave offset %s" % offset)
	for c in wave.convoys:
		c.rendered = false
		LevelManager.enemies_exploded[c.get_instance_id()] = 0
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
			return add_enemy(c,river)

func add_enemy(convoy: Convoy, path: Path2D):
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
	if path.get_child_count() + LevelManager.enemies_exploded[convoy.get_instance_id()] == convoy.count:
		convoy.rendered = true

func enemy_passed():
	# Restart the level when an enemy passes
	clear_wave()
	clear_fruits()
	re_place_fruits(LevelManager.fruits_placed)
	create_wave(curr_wave())

func re_place_fruits(fruits: Dictionary):
	LevelManager.fruits_placed = {}
	for f_id in fruits:
		var f = fruits[f_id]
		place_fruit(f, f.position)
		LevelManager.edit_fruit_placed(f)

func on_level_completed():
	print("level completed!")
	AudioManager.reset()
	var level_won = load("res://level_won.tscn").instantiate()
	SceneManager.change_scene.emit(level_won)
	
func on_wave_completed():
	if len(active_waves) == curr_wave_idx + 1:
		LevelManager.level_completed.emit()
		return
	LevelManager.fruits_placed = {}
	print("wave passed")
	curr_wave_idx += 1
	WaveHistory.add_wave(curr_wave_idx, curr_wave())
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
	LevelManager.enemies_exploded = {}

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

func largest_duration() -> int:
	return curr_wave().convoys.map(func(c): return c.duration).max()
	
func all_convoys_rendered() -> bool:
	return curr_wave().convoys.all(func(c): return c.rendered)

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
