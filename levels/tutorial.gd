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

func _on_skip_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		closed.emit()
		self.queue_free()

func _on_tab_bar_tab_changed(tab: int) -> void:
	tabs[curr_tab_idx].visible = false
	tabs[tab].visible = true
	curr_tab_idx = tab
