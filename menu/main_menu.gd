extends Node2D

func _on_start_button_down() -> void:
	var level1 = load("res://levels/1/1.tscn").instantiate()
	SceneManager.change_scene.emit(level1)


func _on_exit_button_down() -> void:
	get_tree().quit()
