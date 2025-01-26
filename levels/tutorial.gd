extends Node2D

# Enum to track which screen is currently displayed
enum Screen {
	INTRO,
	PREVIEW,
	RESOLUTION,
	SCORE
}

var current_screen = Screen.INTRO

@onready var intro = $intro
@onready var preview = $"preview&fruits"
@onready var resolution = $"resolution&hp"
@onready var score = $score
@onready var btn = $next
var last_tip = false

func _ready() -> void:
	# Initially show only the intro screen
	update_screen_visibility()

func update_screen_visibility() -> void:
	# Hide all screens first
	intro.visible = false
	preview.visible = false
	resolution.visible = false
	score.visible = false
	
	# Show only the current screen
	match current_screen:
		Screen.INTRO:
			intro.visible = true
		Screen.PREVIEW:
			preview.visible = true
		Screen.RESOLUTION:
			resolution.visible = true
		Screen.SCORE:
			score.visible = true
			last_tip = true

func _on_next_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if !last_tip:
			match current_screen:
				Screen.INTRO:
					current_screen = Screen.PREVIEW
				Screen.PREVIEW:
					current_screen = Screen.RESOLUTION
				Screen.RESOLUTION:
					current_screen = Screen.SCORE
					btn.text = "close"
				Screen.SCORE:
					pass
		else:
			self.queue_free()	
		update_screen_visibility()


func _on_skip_gui_input(event: InputEvent) -> void:
	self.queue_free()
