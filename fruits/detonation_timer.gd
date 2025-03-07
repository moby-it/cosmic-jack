extends Label

signal timeout

var duration = 2.0

func _ready() -> void:
	self.text = str(int(duration))
	AudioManager.on_beat.connect(_on_beat)

func _on_beat(_i: int):
		duration -= 1
		self.text = str(int(duration))
		if duration <= 0:
			timeout.emit()
			self.queue_free()
