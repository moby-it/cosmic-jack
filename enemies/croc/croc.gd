extends Node2D

var queue_animation = false
var collision = true

@onready var animation_player: AnimationPlayer = $Animation
@onready var sprite = $Sprite2D
@onready var collision_shape = $Area2D/CollisionShape2D

func _ready() -> void:
	if queue_animation:
		create_animation()
	if not collision:
		disable_collision()

func create_animation():
	var animation = Animation.new()
	animation.resource_name = "scale"
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, "Sprite2D:scale")
	animation.track_insert_key(track_index, 0.0, 0.5)
	animation.track_insert_key(track_index, BpmManager.seconds_per_beat, 0.7)
	animation.track_insert_key(track_index,  BpmManager.seconds_per_beat * 2, 0.5)
	animation.loop_mode = Animation.LOOP_LINEAR
	animation.length = BpmManager.seconds_per_beat * 2
	animation_player.add_animation_library("", animation)
	animation_player.queue("scale")

func disable_collision():
		sprite.modulate.a = 0.5
		collision_shape.disabled = true
