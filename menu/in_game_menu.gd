extends Control

signal closed


func _ready() -> void:
	closed.connect(func(): self.queue_free())

func _on_exit_gui_input(event: InputEvent) -> void:
	if Utils.is_mouse_left_down(event):
		get_tree().quit()

func _on_close_menu_button_down() -> void:
	closed.emit()
