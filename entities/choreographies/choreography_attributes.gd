extends Resource
class_name ChoreographyAttributes

@export var speed = 100
@export var spawn_interval = 1
@export var count = 10
var is_preview = true

@export_file("*.tscn") var path: String
@export_file("*.tscn") var scene: String
