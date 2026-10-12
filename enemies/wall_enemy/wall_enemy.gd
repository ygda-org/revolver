extends CharacterBody2D

const WALL = preload("uid://dmr8fval5mhwj")

const DETECTION_RANGE = 180

var speed = 40
@onready var direction = randi_range(0,1) * 2 - 1

func _ready():
	$EnemyComponent.got_hit.connect(hit)
	$TopPlatform.force_raycast_update()
	if $TopPlatform.is_colliding():
		position.y -= 30

func _physics_process(delta):
	$LineOfSight.target_position = GameState.player.global_position - global_position
	var dist: float = global_position.distance_to(GameState.player.global_position)
	if dist < DETECTION_RANGE and not $LineOfSight.is_colliding():
		velocity = Vector2.ZERO
		# fighting
		if $WallWindown.is_stopped():
			$Anim.play("attack")
			$WallWindown.start()
			$WallTimer.start()
			if (global_position - GameState.player.global_position).x > 0:
				$Anim.flip_h = false
			else:
				$Anim.flip_h = true
		if not $Anim.is_playing():
			$Anim.play("idle")
	elif $WallWindown.is_stopped():
		# wandering
		if is_on_wall() or not $RayCastPivot/WalkoffDetector.is_colliding():
			direction *= -1
		$RayCastPivot.scale.x = direction
		velocity.x = direction * speed
		if velocity.x > 0:
			$Anim.flip_h = true
		elif velocity.x < 0:
			$Anim.flip_h = false
		if velocity.x:
			$Anim.play("walk")
		else:
			$Anim.play("idle")
	if not is_on_floor():
		velocity.y = 50
	
	for i in range(get_slide_collision_count()):
		var col = get_slide_collision(i).get_collider()
		if col is Player:
			col.hit(self)

	
	move_and_slide()


func _on_wall_timer_timeout():
	var dir: float = (GameState.player.global_position - global_position).x
	dir /= abs(dir)
	$SpawnPivot.scale.x = dir
	var wall = WALL.instantiate()
	wall.direction = dir
	get_parent().add_child(wall)
	wall.global_position = $SpawnPivot/SpawnPos.global_position

func hit():
	var particles: CPUParticles2D = load("uid://bytk0fxa7f4hw").instantiate()
	get_parent().add_child(particles)
	particles.global_position = global_position + Vector2(0, 8)
