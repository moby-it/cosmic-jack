extends Sprite2D

var show_logo = false

func _process(delta: float) -> void:
	if show_logo and self.modulate.a < 1:
		self.modulate.a += delta * 0.3
	else:
		var t = Timer.new()
		t.autostart = true
		t.wait_time = 3
		t.one_shot = true
		t.timeout.connect(go_to_menu)
		self.get_parent().add_child(t)

func _on_timer_timeout() -> void:
	show_logo = true

func _on_color_rect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		go_to_menu()

func go_to_menu():
	var n = load("res://menu/main_menu.tscn").instantiate()
	SceneManager.change_scene.emit(n)
