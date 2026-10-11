extends CharacterBody2D
class_name Player

const BULLET = preload("uid://k308fsvc3jvh")

const MAX_SPEED: float = 130.0
const ACCELERATION: float = 900.0
const DECELERATION: float = 1500.0

const JUMP_FORCE: float = 280.0
const MAX_FALL_SPEED: float = 250.0
const GRAVITY: float = 700

const PARRY_WINDOW = 0.15
const PARRY_DAMAGE = 20

@export var accel_curve: Curve
@export var decel_curve: Curve

@export var grav_curve_asc: Curve
@export var grav_curve_dec: Curve

@onready var parry_hitbox = $ParryHitbox

var health: int = 2

var hit_stun_velocity
var slam_velocity: Vector2
var next_bullet_twice: bool = false

func _ready():
	GameState.player = self

func _physics_process(delta):
	
	if Input.is_action_just_pressed("reload") and $ReloadTimer.is_stopped():
		GameState.start_reload.emit()
		$ReloadTimer.start()
	
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
	set_collision_mask_value(6, not Input.is_action_pressed("drop"))
		
	# shooting
	var mouse_offset: Vector2 = (get_global_mouse_position() - global_position)/6
	mouse_offset.y /= 2
	$Camera2D.target_offset = mouse_offset
	$Camera2D.target_offset = $Camera2D.target_offset.limit_length(40)
	if Input.is_action_just_pressed("shoot") and $ShotCD.is_stopped() and $ReloadTimer.is_stopped():
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
		if next_bullet_twice:
			next_bullet_twice = false
			var bullet2 = bullet.duplicate()
			bullet2.resource = resource
			bullet2.direction = shot_dir
			bullet2.global_position = global_position
			bullet2.player = self
			get_tree().create_timer(0.1).timeout.connect(get_parent().add_child.bind(bullet2))
			if resource.recoil:
				velocity.y /= 3
				velocity += resource.recoil * -shot_dir
				$RecoilLock.start()
		if resource.recoil:
			velocity.y /= 3
			velocity += resource.recoil * -shot_dir
			$RecoilLock.start()
		# PARRY IT - Maelle
		if resource.effect == BulletResource.effects.PARRY:
			parry_hitbox.monitoring = true
			get_tree().create_timer(PARRY_WINDOW).timeout.connect(disable_parry)
	if not $HitStun.is_stopped():
		velocity = hit_stun_velocity
	if slam_velocity:
		velocity = slam_velocity
	move_and_slide()

func disable_parry():
	parry_hitbox.monitoring = false

func hit(hitter: Node2D):
	print('hit!')
	if $InvicibilityFrames.is_stopped():
		$InvicibilityFrames.start()
	else:
		return
	health -= 1
	$HitStun.start()
	hit_stun_velocity = 55 * hitter.global_position.direction_to(global_position)
	if health <= 0:
		die()

func die():
	print("I'm dead!")

func dash(dir, speed):
	velocity = dir * speed
	$DashDur.start()
	# still need to add dash invincibility


func _on_reload_timer_timeout() -> void:
	GameState.reload()
	GameState.stop_reload.emit()

# hit enemy
func _on_parry_hitbox_body_entered(body):
	var enemy_component = body.find_child("EnemyComponent")
	if not enemy_component:
		return
	enemy_component.hit(PARRY_DAMAGE)

# hit enemy bullet
func _on_parry_hitbox_area_entered(area):
	if not "direction" in area:
		return
	area.direction = global_position.direction_to(GameState.get_closest_enemy_to_position(global_position).global_position)
	if not "parried" in area:
		return
	area.parried = true
	area.set_collision_mask_value(2, true)

func shift(dir, dist):
	var target: Vector2 = dir*dist
	$ShiftDetector.target_position = target
	$ShiftDetector.force_raycast_update()
	if $ShiftDetector.is_colliding():
		global_position = $ShiftDetector.get_collision_point()
	else:
		global_position += target

func slam():
	slam_velocity = Vector2(0, 350)
	$SlamHitbox.monitoring = true


func _on_slam_hitbox_body_entered(body):
	
	var comp = body.find_child("EnemyComponent")
	if comp:
		comp.hit(load("uid://dof6lvg6wev5k").damage)
		$InvicibilityFrames.start()
		if comp.health > 0:
			slam_velocity = Vector2.ZERO
			$SlamHitbox.monitoring = false
	else:
		slam_velocity = Vector2.ZERO
		$SlamHitbox.monitoring = false
		$InvicibilityFrames.start()
