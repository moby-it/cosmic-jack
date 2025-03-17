extends Control

signal closed

@onready var container = $ColorRect/MarginContainer/VBoxContainer/History
@onready var exit_button = $ColorRect/Exit

var disable_replay_past_levels: bool = false

func _ready() -> void:
	closed.connect(func(): self.queue_free())
	
	if disable_replay_past_levels:
		# Clear container first to ensure clean state
		for child in container.get_children():
			child.queue_free()
			
		# When a player loses, show only the current level they lost
		var current_wave = WaveHistory.history.back()
		if current_wave:
			# No label needed
			
			_render_history(current_wave)
		
		# Leave exit game unchanged - no need to modify it
	else:
		# Show all wave history entries, but only allow retry for the current level
		var current_idx = WaveHistory.history.size() - 1
		
		for i in range(WaveHistory.history.size()):
			var h = WaveHistory.history[i]
			var is_current = (i == current_idx)
			_render_history(h, is_current)

func _on_exit_gui_input(event: InputEvent) -> void:
	if Utils.is_mouse_left(event):
		get_tree().quit()

func _on_close_menu_button_down() -> void:
	closed.emit()

func _render_history(history, show_retry_button: bool = true):
	var wave_entry = load("res://menu/wave_entry.tscn").instantiate()
	wave_entry.index = history["index"]
	wave_entry.hp = history["hp"]
	wave_entry.wave = history["wave"]
	wave_entry.show_retry_button = show_retry_button
	container.add_child(wave_entry)
