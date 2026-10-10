extends CharacterBody2D

const SHOT = preload("uid://cidxef737ydfs")

const SPEED = 60
const ACCELERATION = 80

const DETECTION_RANGE = 300
const DESIRED_DISTANCE = 150

func _physics_process(delta):
	var dist: float = global_position.distance_to(GameState.player.global_position)
	if dist < DETECTION_RANGE:
		$Anim.play("locked")
		# fighting
		if $ShotTimer.is_stopped():
			$ShotTimer.start()
		var direction: Vector2 = global_position.direction_to(GameState.player.global_position)
		if dist > DESIRED_DISTANCE:
			velocity = velocity.move_toward(direction*SPEED, ACCELERATION*delta)
		else:
			velocity = velocity.move_toward(-direction*SPEED, ACCELERATION*delta)
	else:
		# wandering
		$Anim.play("fly")
		velocity = velocity.move_toward(Vector2.ZERO, ACCELERATION*delta)
	move_and_slide()

func _on_shot_timer_timeout():
	if global_position.distance_to(GameState.player.global_position) > DETECTION_RANGE:
		return
	$Indicator.start()


func _on_indicator_animation_finished():
	if global_position.distance_to(GameState.player.global_position) > DETECTION_RANGE:
		return
	var shots = [SHOT.instantiate(),SHOT.instantiate(),SHOT.instantiate()]
	for i in range(3):
		shots[i].direction = global_position.direction_to(GameState.player.global_position)
		shots[i].direction = shots[i].direction.rotated((PI/6)*(i-1))
		shots[i].global_position = global_position
		get_parent().add_child(shots[i])
