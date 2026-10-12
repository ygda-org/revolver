extends CharacterBody2D
class_name DashEnemy

@export var speed: float = 80.0
@export var direction: int = -1

var player_not_seen: bool = true

func _ready():
	$RaycastPivot.scale.x = direction
	$EnemyComponent.got_hit.connect(hit)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y = 50
	if is_on_wall() or not $RaycastPivot/WalkoffDetector.is_colliding():
		direction *= -1
	$RaycastPivot.scale.x = direction
	velocity.x = direction * speed
	if $RaycastPivot/PlayerDetector.is_colliding():
		if player_not_seen:
			Sfx.play(Sfx.Labels.SCORPION_DETECTION)
		$RaycastPivot/Light.energy = lerp($RaycastPivot/Light.energy, 4.0, delta * 5)
		player_not_seen = false
		$Anim.play("run")
		velocity.x *= 2
	else:
		$Anim.play("default")
		player_not_seen = true
		$RaycastPivot/Light.energy = lerp($RaycastPivot/Light.energy, 1.0, delta * 5)
	if velocity.x > 0:
		$Anim.flip_h = true
	elif velocity.x < 0:
		$Anim.flip_h = false
	for i in range(get_slide_collision_count()):
		var col = get_slide_collision(i).get_collider()
		if col is Player:
			col.hit(self)
		if col is DashEnemy:
			pass
	
	move_and_slide()

func hit():
	var particles: CPUParticles2D = load("uid://cjjrsuqk6dbgq").instantiate()
	get_parent().add_child(particles)
	particles.global_position = global_position + Vector2(0, 7)
