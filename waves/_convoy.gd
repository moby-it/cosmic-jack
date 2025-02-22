extends Resource
class_name Convoy

## in beats
@export var duration = 24
@export var count = 10
@export var delay = 0

@export var river: PackedScene
@export var enemy: PackedScene

var rendered = false
