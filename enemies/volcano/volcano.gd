extends CharacterBody2D

const PELLET = preload("uid://ddtan3gghk3bx")

const SPEED = 40
const ACCELERATION = 60

const DETECTION_RANGE = 200
const DESIRED_HEIGHT = 100

func _ready():
	$EnemyComponent.got_hit.connect(hit)

func _physics_process(delta):
	$LineOfSight.target_position = GameState.player.global_position - global_position
	var dist: float = global_position.distance_to(GameState.player.global_position)
	if dist < DETECTION_RANGE and not $LineOfSight.is_colliding():
		# fighting
		if $ShotTimer.is_stopped():
			$ShotTimer.start()
		var target_pos: Vector2 = GameState.player.global_position + Vector2(0, -DESIRED_HEIGHT)
		velocity = velocity.move_toward(SPEED * global_position.direction_to(target_pos), delta*ACCELERATION)
	else:
		# wandering
		velocity = velocity.move_toward(Vector2.ZERO, ACCELERATION*delta)
	
	for i in range(get_slide_collision_count()):
		var col = get_slide_collision(i).get_collider()
		if col is Player:
			col.hit(self)
	if $CeilingCheck.is_colliding():
		velocity.y = abs(velocity.y)
	move_and_slide()


func _on_shot_timer_timeout():
	var shot_dir: Vector2 = Vector2(0,-1).rotated(randf_range(-PI/5, PI/5))
	var pellet = PELLET.instantiate()
	pellet.velocity = shot_dir * 70
	get_parent().add_child(pellet)
	pellet.global_position = $Marker2D.global_position

func hit():
	var particles: CPUParticles2D = load("uid://bj2bmynw4swka").instantiate()
	get_parent().add_child(particles)
	particles.global_position = global_position
