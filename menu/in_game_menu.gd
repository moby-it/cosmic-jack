extends Control

signal closed

@onready var container = $ColorRect/MarginContainer/VBoxContainer/History

func _ready() -> void:
	closed.connect(func(): self.queue_free())

func _on_exit_gui_input(event: InputEvent) -> void:
	if Utils.is_mouse_left_down(event):
		get_tree().quit()

func _on_close_menu_button_down() -> void:
	closed.emit()

func _render_history(history):
	var wave_entry = load("res://menu/wave_entry.tscn").instantiate()
	wave_entry.index = history["index"]
	wave_entry.wave = history["wave"]
	container.add_child(wave_entry)
