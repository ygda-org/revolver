extends CharacterBody2D

const SPEED = 70
const WAVE_AMPLITUDE = 3

var targeting = false
@onready var target_position = global_position
var delta_since_set: float = 0.0

func _ready():
	velocity = Vector2.ZERO

func set_target_position(new_pos):
	target_position = new_pos
	delta_since_set = 0.0

func _physics_process(delta):
	delta_since_set += delta
	if targeting:
		velocity = global_position.direction_to(target_position) * SPEED
		velocity += velocity.orthogonal() * WAVE_AMPLITUDE * sin(delta_since_set)
	else:
		velocity += (-position.normalized() * SPEED/30) + Vector2(randf_range(-5, 5), randf_range(-5,5))
	move_and_slide()
