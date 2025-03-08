extends Level

var input_enabled = false


func _ready() -> void:
	active_waves = waves
	pass

func _input(event: InputEvent) -> void:
	if not input_enabled:
		return
	super._input(event)


func on_fruit_list_selected(i: String) -> void:
	if not input_enabled:
		return
	super.on_fruit_list_selected(i)

func _on_resolve_button_down():
	for f: Node2D in get_tree().get_nodes_in_group("fruits"):
		var new_fruit = Fruits.create_fruit(active_fruit_name)
		new_fruit.position = f.position
		f.queue_free()
		self.add_child(new_fruit)
			
	super._on_resolve_button_down()
