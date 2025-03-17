extends VBoxContainer

@export var wave: Wave
@export var index: int
@export var hp: int = 0
var show_retry_button: bool = true

@onready var container = $Panel/MarginContainer/WaveProps
@onready var retry_button = $Retry

func _ready() -> void:
	var title = create_label("%s-%s: %s" % [WaveHistory.level_index, index + 1, wave.title])
	title.add_theme_font_size_override("font_size", 48)
	var subtitle = create_label(wave.subtitle)
	subtitle.add_theme_font_size_override("font_size", 32)
	container.add_child(title)
	#container.add_child(subtitle)
	#container.add_child(create_label("hp: %s" % hp))
	
	# Hide retry button if not showing it
	if not show_retry_button and is_instance_valid(retry_button):
		retry_button.visible = false

func create_label(text: String):
	var l = Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l

func _on_retry_gui_input(event: InputEvent) -> void:
	if Utils.is_mouse_left(event) and show_retry_button:
		WaveHistory.level_change.emit(index, hp)
