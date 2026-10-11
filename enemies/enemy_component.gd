extends Node2D
class_name EnemyComponent

signal got_hit

@export var health: int = 50
@export var repair_add_amount: float = 0.2

var burn_dur: int = 0

func _ready():
	GameState.active_enemies.append(self)
	var room = get_parent()
	while not room is Room:
		room = room.get_parent()
	room.enemies.append(self)

func hit(dmg: int):
	got_hit.emit()
	health -= dmg
	if health <= 0:
		die()
		return

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
