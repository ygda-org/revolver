extends CharacterBody2D

const WALL = preload("uid://dmr8fval5mhwj")

const DETECTION_RANGE = 180

const SPEED = 40
@onready var direction = randi_range(0,1) * 2 - 1

func _physics_process(delta):
	var dist: float = global_position.distance_to(GameState.player.global_position)
	if dist < DETECTION_RANGE:
		velocity = Vector2.ZERO
		# fighting
		if $WallTimer.is_stopped():
			$WallTimer.start()
		if (global_position - GameState.player.global_position).x > 0:
			$Anim.flip_h = false
		else:
			$Anim.flip_h = true
	else:
		# wandering
		if is_on_wall() or not $RayCastPivot/WalkoffDetector.is_colliding():
			direction *= -1
		$RayCastPivot.scale.x = direction
		velocity.x = direction * SPEED
		if velocity.x > 0:
			$Anim.flip_h = true
		elif velocity.y < 0:
			$Anim.flip_h = false
	if not is_on_floor():
		velocity.y = 50
	
	for i in range(get_slide_collision_count()):
		var col = get_slide_collision(i).get_collider()
		if col is Player:
			col.hit(self)
	
	if velocity.x:
		$Anim.play("walk")
	else:
		$Anim.play("idle")
	
	move_and_slide()


func _on_wall_timer_timeout():
	var dir: float =(GameState.player.global_position - global_position).x
	dir /= abs(dir)
	$SpawnPivot.scale.x = dir
	var wall = WALL.instantiate()
	wall.direction = dir
	get_parent().add_child(wall)
	wall.global_position = $SpawnPivot/SpawnPos.global_position
