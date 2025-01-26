extends Label

var file = 'res://version.txt'

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var version = get_text_file_content(file)
	self.text = version

func get_text_file_content(filePath):
	var file = FileAccess.open(filePath, FileAccess.READ)
	var content = file.get_as_text()
	return content
