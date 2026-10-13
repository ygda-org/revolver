extends Node2D
class_name EnemyComponent

signal got_hit

@export var health: int = 50
@export var repair_add_amount: float = 0.2

@export var death_sfx: SFX.Labels

var burn_dur: int = 0

@onready var anim = get_parent().get_node_or_null("Anim")

## for camera
var active: bool

func _ready():
	GameState.active_enemies.append(self)
	var room = get_parent()
	while not room is Room:
		room = room.get_parent()
	room.enemies.append(self)
	health *= -(0.5/(1+0.6*GameState.cleared_levels))+1.5

func _process(delta):
	var active_threshold = 200
	if "DIST" in get_parent():
		active_threshold = get_parent().dist
	active = abs(GameState.player.global_position.x - global_position.x) < active_threshold and global_position.distance_to(GameState.player.global_position) < active_threshold
	if not anim:
		print("Animations not found!")
		return
	if $FlashTimer.is_stopped():
		anim.material.set_shader_parameter("flash_modulate", clampf(anim.material.get_shader_parameter("flash_modulate")-(1/$FlashTimer.wait_time)*delta, 0, 1))
	else:
		anim.material.set_shader_parameter("flash_modulate", clampf(anim.material.get_shader_parameter("flash_modulate")+(1/$FlashTimer.wait_time)*delta, 0, 1))

func hit(dmg: int):
	got_hit.emit()
	health -= dmg
	if health <= 0:
		Sfx.play(death_sfx)
		die()
		return
	if anim:
		$FlashTimer.start()

func die():
	# repair
	GameState.enemy_death(self)
	get_parent().call_deferred("queue_free")

func freeze(duration: float):
	$FreezeTimer.wait_time = duration
	$FreezeTimer.start()
	if "speed" in get_parent():
		get_parent().speed /= 2

func _on_freeze_timer_timeout():
	if "speed" in get_parent():
		get_parent().speed *= 2

func burn(amount):
	burn_dur += amount
	$BurnTimer.start()

func _on_burn_timer_timeout():
	health -= 1
	burn_dur -= 1
	if burn_dur:
		$BurnTimer.start()
