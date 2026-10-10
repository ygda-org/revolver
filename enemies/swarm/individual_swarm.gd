extends CharacterBody2D

const SPEED = 70
const WAVE_AMPLITUDE = 3

var targeting = false
@onready var target_position = global_position
var delta_since_set: float = 0.0

func _ready():
	$AnimatedSprite2D.sprite_frames = load(["uid://dnofs8ub7au7f", "uid://ud41rkxo0p5u"][randi_range(0,1)])
	$AnimatedSprite2D.play("fly")
	velocity = Vector2.ZERO

func set_target_position(new_pos):
	target_position = new_pos
	delta_since_set = 0.0

func _physics_process(delta):
	delta_since_set += delta
	if targeting:
		var dir: Vector2 = global_position.direction_to(target_position)
		velocity = global_position.direction_to(target_position) * SPEED
		velocity += dir * WAVE_AMPLITUDE * sin(delta_since_set)
		$AnimatedSprite2D.flip_h = bool(clampf(velocity.x, 0, 1))
	else:
		velocity += (-position.normalized() * SPEED/30) + Vector2(randf_range(-5, 5), randf_range(-5,5))
	
	for i in range(get_slide_collision_count()):
		var col = get_slide_collision(i).get_collider()
		if col is Player:
			col.hit()

	move_and_slide()
