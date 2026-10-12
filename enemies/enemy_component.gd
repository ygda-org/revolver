extends Node2D
class_name EnemyComponent

signal got_hit

@export var health: int = 50
@export var repair_add_amount: float = 0.2

@export var death_sfx: SFX.Labels

var burn_dur: int = 0

@onready var anim = get_parent().get_node_or_null("Anim")

func _ready():
	GameState.active_enemies.append(self)
	var room = get_parent()
	while not room is Room:
		room = room.get_parent()
	room.enemies.append(self)

func _process(delta):
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
	# need to reduce speed

func _on_freeze_timer_timeout():
	pass # Replace with function body.

func burn(amount):
	burn_dur += amount
	$BurnTimer.start()

func _on_burn_timer_timeout():
	health -= 1
	burn_dur -= 1
	if burn_dur:
		$BurnTimer.start()
