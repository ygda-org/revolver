extends CharacterBody2D
class_name Player

signal dash_ended

const BULLET = preload("uid://k308fsvc3jvh")

const MAX_SPEED: float = 130.0
const ACCELERATION: float = 900.0
const DECELERATION: float = 1500.0

const JUMP_FORCE: float = 280.0
const MAX_FALL_SPEED: float = 250.0
const GRAVITY: float = 700

const PREPARRY_WINDOW = 0.18
## actualy window is this minus preparry window
const PARRY_WINDOW = 0.25
const PARRY_DAMAGE = 20

@export var accel_curve: Curve
@export var decel_curve: Curve

@export var grav_curve_asc: Curve
@export var grav_curve_dec: Curve

@onready var parry_hitbox = $CenterArmPivot/Arm/ParryHitbox
@onready var arm = $CenterArmPivot/Arm
@onready var shot_position = $CenterArmPivot/Arm/BarrelPosition

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
	if $DashDur.is_stopped() and $RecoilLock.is_stopped():
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
	if $ParryAnimDur.is_stopped():
		arm.look_at(get_global_mouse_position())
		arm.rotation -= PI/2
	if Input.is_action_just_pressed("shoot") and $ShotCD.is_stopped() and $ReloadTimer.is_stopped() and $ParryAnimDur.is_stopped():
		$ShotCD.start()
		var resource: BulletResource = GameState.get_bullet()
		$Camera2D.add_trauma(resource.shake_trauma)
		var shot_dir: Vector2 = global_position.direction_to(get_global_mouse_position())
		var bullet = BULLET.instantiate()
		bullet.resource = resource
		bullet.direction = shot_dir
		bullet.global_position = shot_position.global_position
		bullet.player = self
		get_parent().add_child(bullet)
		if next_bullet_twice:
			next_bullet_twice = false
			var bullet2 = bullet.duplicate()
			bullet2.resource = resource
			bullet2.direction = shot_dir
			bullet2.global_position = shot_position.global_position
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
			get_tree().create_timer(PREPARRY_WINDOW).timeout.connect(toggle_parry.bind(true))
			get_tree().create_timer(PARRY_WINDOW).timeout.connect(toggle_parry.bind(false))
			var tween = get_tree().create_tween()
			tween.tween_property(arm, "rotation", arm.rotation - PI/6, PREPARRY_WINDOW)
			tween.tween_property(arm, "rotation", arm.rotation + PI/3, PARRY_WINDOW-PREPARRY_WINDOW)
			$ParryAnimDur.start()
	if not $HitStun.is_stopped():
		print(hit_stun_velocity)
		velocity = hit_stun_velocity
		hit_stun_velocity -= hit_stun_velocity * 10 * delta
		if hit_stun_velocity.length_squared() < 100:
			hit_stun_velocity = hit_stun_velocity.normalized() * 10
	if slam_velocity:
		velocity = slam_velocity
	
	# animations
	if $ParryAnimDur.is_stopped():
		if velocity.x > 0:
			$Anim.flip_h = false
			$CenterArmPivot.scale.x = 1
		elif velocity.x < 0:
			$Anim.flip_h = true
			$CenterArmPivot.scale.x = -1
	
	move_and_slide()

func toggle_parry(b: bool):
	parry_hitbox.monitoring = b

func hit(hitter: Node2D):
	print('hit!')
	if $InvicibilityFrames.is_stopped():
		$InvicibilityFrames.start()
	else:
		return
	health -= 1
	$HitStun.start()
	hit_stun_velocity = 150 * hitter.global_position.direction_to(global_position)
	if health <= 0:
		die()

func die():
	print("I'm dead!")

func dash(dir, speed):
	velocity = dir * speed
	$DashDur.start()
	$InvicibilityFrames.start()
	$DashDur.timeout.connect(dash_ended.emit)


func _on_reload_timer_timeout() -> void:
	GameState.reload()
	GameState.stop_reload.emit()

# hit enemy
func _on_parry_hitbox_body_entered(body):
	var enemy_component = body.find_child("EnemyComponent")
	if not enemy_component:
		$Camera2D.add_trauma(0.7)
		return
	$Camera2D.add_trauma(1.0)
	enemy_component.hit(PARRY_DAMAGE)

# hit enemy bullet
func _on_parry_hitbox_area_entered(area):
	$Camera2D.add_trauma(1.2)
	if area is PlayerBullet:
		area.vel = 400 * global_position.direction_to(GameState.get_closest_enemy_to_position(global_position).global_position)
		area.damage *= 2.5
	if "velocity" in area:
		area.parried = true
		area.set_collision_mask_value(2, true)
		area.velocity = 200 * global_position.direction_to(GameState.get_closest_enemy_to_position(global_position).global_position)
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
	$Camera2D.add_trauma(0.6)
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
