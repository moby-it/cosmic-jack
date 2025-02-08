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
	var tween := self.create_tween().set_loops()
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), BpmManager.seconds_per_beat * 2).set_trans(Tween.TRANS_SPRING).set_delay(BpmManager.time_to_next_beat)
	tween.tween_property(self, "scale", Vector2(1, 1), BpmManager.seconds_per_beat * 2).set_trans(Tween.TRANS_SPRING).set_delay(BpmManager.time_to_next_beat)
	tween.bind_node(self)

func disable_collision():
		sprite.modulate.a = 0.5
		collision_shape.disabled = true
