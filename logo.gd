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
		t.timeout.connect(_on_logo_timer_end)
		self.get_parent().add_child(t)

func _on_timer_timeout() -> void:
	show_logo = true

func _on_logo_timer_end():
	var n = load("res://menu/welcome.tscn").instantiate()
	SceneManager.change_scene.emit(n)
	


func _on_color_rect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var n = load("res://menu/welcome.tscn").instantiate()
		SceneManager.change_scene.emit(n)
