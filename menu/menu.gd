extends Node2D


func _on_info_button_down() -> void:
	var welcome = load("res://menu/welcome.tscn").instantiate()
	SceneManager.change_scene.emit(welcome)
