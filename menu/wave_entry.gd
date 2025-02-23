extends VBoxContainer

@export var wave: Wave
@export var index: int
@export var hp: int = 0

@onready var container = $Panel/MarginContainer/WaveProps

func _ready() -> void:
	var title = create_label(wave.title)
	title.add_theme_font_size_override("font_size", 62)
	var subtitle = create_label(wave.subtitle)
	subtitle.add_theme_font_size_override("font_size", 48)
	container.add_child(title)
	#container.add_child(subtitle)
	#container.add_child(create_label("hp: %s" % hp))

func create_label(text: String):
	var l = Label.new()
	l.text = text
	return l

func _on_retry_gui_input(event: InputEvent) -> void:
	if Utils.is_mouse_left(event):
		WaveHistory.level_change.emit(index, hp)
