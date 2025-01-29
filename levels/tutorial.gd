extends ColorRect

signal closed

@onready var intro = $Intro
@onready var preview = $Preview
@onready var fruits = $Fruits
@onready var resolution = $Resolution
@onready var time_travel = $TimeTravel
@onready var score = $Score
@onready var close = $Close

@onready var tabs = [
	intro,
	preview,
	fruits,
	resolution,
	time_travel,
	score
]

var curr_tab_idx = 0

func _ready() -> void:
	tabs[curr_tab_idx].visible = true

func _on_tab_bar_tab_changed(tab: int) -> void:
	tabs[curr_tab_idx].visible = false
	tabs[tab].visible = true
	curr_tab_idx = tab


func _on_close_button_down() -> void:
	closed.emit()
	self.queue_free()
