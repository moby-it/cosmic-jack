extends Node2D


func _on_info_button_down() -> void:
	var welcome = load("res://menu/welcome.tscn").instantiate()
	SceneManager.change_scene.emit(welcome)


func _on_start_button_down() -> void:
	#var level1: Level = load("res://levels/level.tscn").instantiate()
	#level1.waves = [
		#load("res://levels/1/1-1.wave.tres")
	#]
	#level1.health = 3
	var level1 = load("res://levels/1/1.tscn").instantiate()
	SceneManager.change_scene.emit(level1)
