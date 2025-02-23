extends Node2D

var queue_animation = false
var collision = true
var convoy_id


@onready var animation_player: AnimationPlayer = $Animation
@onready var sprite = $Sprite2D
@onready var collision_shape = $Area2D/CollisionShape2D

var tween: Tween

func _ready() -> void:
	if queue_animation:
		create_animation()
	if not collision:
		disable_collision()

func create_animation():
	tween = self.create_tween().set_loops()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), AudioManager.seconds_per_beat / 2).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "scale", Vector2(1, 1), AudioManager.seconds_per_beat / 2).set_trans(Tween.TRANS_QUINT)
	tween.bind_node(self)

func disable_collision():
		sprite.modulate.a = 0.5
		collision_shape.disabled = true

func pause_animate():
	if is_instance_valid(tween):
		tween.pause()
		
func resume_animate():
	if is_instance_valid(tween):
		tween.play()
