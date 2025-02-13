extends Node2D

signal closed

@onready var container = $ColorRect/History

func _ready() -> void:
	closed.connect(func(): self.queue_free())
	for h in WaveHistory.history:
		_render_history(h)

func _on_exit_gui_input(event: InputEvent) -> void:
	if Utils.is_mouse_left(event):
		get_tree().quit()

func _on_close_menu_button_down() -> void:
	closed.emit()

func _render_history(history):
	var wave_entry = load("res://menu/wave_entry.tscn").instantiate()
	wave_entry.index = history["index"]
	wave_entry.hp = history["hp"]
	container.add_child(wave_entry)
