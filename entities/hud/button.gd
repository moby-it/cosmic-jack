extends Button

signal resolve_wave

func _on_pressed() -> void:
	resolve_wave.emit()
