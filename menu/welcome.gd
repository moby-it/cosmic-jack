extends Node2D

func _on_content_meta_clicked(meta: Variant) -> void:
	OS.shell_open(meta)


func _on_next_button_down() -> void:
	var menu = load("res://menu/main_menu.tscn").instantiate()
	SceneManager.change_scene.emit(menu)
