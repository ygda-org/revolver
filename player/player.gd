extends CharacterBody2D
class_name Player

const BULLET = preload("uid://k308fsvc3jvh")

const MAX_SPEED: float = 130.0
const ACCELERATION: float = 900.0
const DECELERATION: float = 1500.0

const JUMP_FORCE: float = 280.0
const MAX_FALL_SPEED: float = 250.0
const GRAVITY: float = 700

@export var accel_curve: Curve
@export var decel_curve: Curve

@export var grav_curve_asc: Curve
@export var grav_curve_dec: Curve

var health: int = 2

func _ready():
	GameState.player = self

func _physics_process(delta):
	
	if Input.is_action_just_pressed("reload"):
		GameState.reload()
	
	# gravity & jumping
	if not is_on_floor():
		var grav_mult: float = 1.0
		if velocity.y < 0:
			grav_mult = grav_curve_asc.sample(abs(velocity.y/JUMP_FORCE))
		else:
			grav_mult = grav_curve_dec.sample(velocity.y/MAX_FALL_SPEED)
		velocity.y += GRAVITY * grav_mult * delta
	else:
		$CoyoteTime.start()
	if Input.is_action_just_pressed("jump"):
		$JumpBuffer.start()
	elif Input.is_action_just_released("jump"):
		velocity.y /= 1.7
	if not $CoyoteTime.is_stopped() and not $JumpBuffer.is_stopped():
		$CoyoteTime.stop()
		$JumpBuffer.stop()
		velocity.y -= JUMP_FORCE
	
	# left right movement
	if $DashDur.is_stopped():
		var dir: float = Input.get_axis("left", "right")
		if dir:
			velocity.x += dir * ACCELERATION * accel_curve.sample(abs(velocity.x/MAX_SPEED)) * delta
		if dir * velocity.x <= 0 and $RecoilLock.is_stopped():
			velocity.x = move_toward(velocity.x, 0, DECELERATION * decel_curve.sample(abs(velocity.x/MAX_SPEED)) * delta)
		velocity.x = clampf(velocity.x, -MAX_SPEED, MAX_SPEED)
	
	# shooting
	var mouse_offset: Vector2 = (get_global_mouse_position() - global_position)/6
	mouse_offset.y /= 2
	$Camera2D.target_offset = mouse_offset
	$Camera2D.target_offset = $Camera2D.target_offset.limit_length(40)
	if Input.is_action_just_pressed("shoot") and $ShotCD.is_stopped():
		$ShotCD.start()
		var resource: BulletResource = GameState.get_bullet()
		$Camera2D.add_trauma(resource.shake_trauma)
		var shot_dir: Vector2 = global_position.direction_to(get_global_mouse_position())
		var bullet = BULLET.instantiate()
		bullet.resource = resource
		bullet.direction = shot_dir
		bullet.global_position = global_position
		bullet.player = self
		get_parent().add_child(bullet)
		if resource.recoil:
			velocity.y /= 3
			velocity += resource.recoil * -shot_dir
			$RecoilLock.start()
	
	move_and_slide()

func hit():
	health -= 1
	if health <= 0:
		die()

func die():
	print("I'm dead!")

func dash(dir, speed):
	velocity = dir * speed
	$DashDur.start()
	# still need to add dash invincibility
