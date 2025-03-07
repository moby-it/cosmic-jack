extends Level

var input_enabled = false


func _ready() -> void:
	active_waves = waves
	pass

func _input(event: InputEvent) -> void:
	if not input_enabled:
		return
	if not play_area.get_rect().has_point(get_global_mouse_position()):
		return
	if Input.is_key_pressed(KEY_CTRL) and is_instance_valid(active_fruit):
		active_fruit.queue_free()
	if not Input.is_key_pressed(KEY_CTRL) and not is_instance_valid(active_fruit) and not is_instance_valid(wave_announcer):
		add_active_fruit()
	if event.is_action_pressed("Restart") and preview():
		clear_wave()
		render_convoys(curr_wave())

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
				print("should start moving fruits")
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
