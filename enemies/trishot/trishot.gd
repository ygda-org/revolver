extends CharacterBody2D

const SHOT = preload("uid://cidxef737ydfs")

var speed = 60
const ACCELERATION = 80

const DETECTION_RANGE = 200
const DESIRED_DISTANCE = 150

func _ready():
	$EnemyComponent.got_hit.connect(hit)

func _physics_process(delta):
	$CanSeePlayer.target_position = GameState.player.global_position - global_position
	var dist: float = global_position.distance_to(GameState.player.global_position)
	if dist < DETECTION_RANGE and not $CanSeePlayer.is_colliding():
		Sfx.play(Sfx.Labels.ASPID_HOVER)
		
		$Anim.play("locked")
		
		# fighting
		if $ShotTimer.is_stopped():
			$ShotTimer.start()
		var direction: Vector2 = global_position.direction_to(GameState.player.global_position)
		if dist > DESIRED_DISTANCE:
			velocity = velocity.move_toward(direction*speed, ACCELERATION*delta)
		else:
			velocity = velocity.move_toward(-direction*speed, ACCELERATION*delta)
		$Anim.flip_h = direction.x > 0
		$Indicator.flip_h = direction.x > 0
	else:
		# wandering
		$Anim.play("fly")
		velocity = velocity.move_toward(Vector2.ZERO, ACCELERATION*delta)
	
	for i in range(get_slide_collision_count()):
		var col = get_slide_collision(i).get_collider()
		if col is Player:
			col.hit(self)
	move_and_slide()

func _on_shot_timer_timeout():
	if global_position.distance_to(GameState.player.global_position) > DETECTION_RANGE:
		return
	$Indicator.visible = true
	$Indicator.play("default")
	Sfx.play(Sfx.Labels.ASPID_WARNING)


func _on_indicator_animation_finished():
	$Indicator.visible = false
	if global_position.distance_to(GameState.player.global_position) > DETECTION_RANGE:
		return
	Sfx.play(Sfx.Labels.ASPID_FIRE)
	var shots = [SHOT.instantiate(),SHOT.instantiate(),SHOT.instantiate()]
	for i in range(3):
		shots[i].direction = global_position.direction_to(GameState.player.global_position)
		shots[i].direction = shots[i].direction.rotated((PI/6)*(i-1))
		get_parent().add_child(shots[i])
		shots[i].global_position = global_position

func hit():
	var particles: CPUParticles2D = load("uid://sxegonprvhwk").instantiate()
	get_parent().add_child(particles)
	particles.global_position = global_position
