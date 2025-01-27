extends Node2D


func _on_info_button_down() -> void:
	var welcome = load("res://menu/welcome.tscn").instantiate()
	SceneManager.change_scene.emit(welcome)


func _on_start_button_down() -> void:
	var level1 = load("res://levels/1/1.tscn").instantiate()
	SceneManager.change_scene.emit(level1)
