extends CharacterBody2D
class_name BounceEnemy

@export var speed: float = 80.0

@export var gravity_curve: Curve

var direction: float = 0.0

const GRAVITY = 700
const JUMP_FORCE = 300
const MAX_FALL_SPEED = 300

const DETECTION_RANGE = 200
var saw_player_from_air: bool = false
var was_in_air: bool = false

func _ready():
	$EnemyComponent.got_hit.connect(hit)

func _physics_process(delta):
	$LineOfSight.target_position = GameState.player.global_position - global_position
	if not is_on_floor():
		if direction > 0:
			$Anim.flip_h = true
			$LightFlip.scale.x = -1
		elif direction < 0:
			$Anim.flip_h = false
			$LightFlip.scale.x = 1
		was_in_air = true
		if not saw_player_from_air:
			saw_player_from_air = not $LineOfSight.is_colliding()
		velocity.y = move_toward(velocity.y, MAX_FALL_SPEED, GRAVITY * delta * gravity_curve.sample(abs(velocity.y/MAX_FALL_SPEED)))
		velocity.x = speed * direction
	else:
		if was_in_air:
			$Anim.play("default")
			$GroundParticles.emitting = true
		was_in_air = false
		velocity.x = 0.0
		if global_position.distance_to(GameState.player.global_position) < DETECTION_RANGE and (not $LineOfSight.is_colliding() or saw_player_from_air):
			direction = sign(global_position.direction_to(GameState.player.global_position).x)
		else:
			direction = 0.0
	
	for i in range(get_slide_collision_count()):
		var col = get_slide_collision(i).get_collider()
		if col is Player:
			col.hit(self)
	
	move_and_slide()

func _on_jump_windup_timer_timeout():
	if not is_on_floor():
		return
	if global_position.distance_to(GameState.player.global_position) < DETECTION_RANGE:
		Sfx.play(Sfx.Labels.LEGGY)
	$Anim.play("extended")
	velocity.y -= JUMP_FORCE

func hit():
	var particles: CPUParticles2D = load("uid://crl7tr1b01kry").instantiate()
	get_parent().add_child(particles)
	particles.global_position = global_position


func _on_anim_animation_finished():
	if $Anim.animation == "default":
		_on_jump_windup_timer_timeout()
