extends Node2D
class_name EnemyComponent

@export var health: int = 50

func hit(resource: BulletResource):
	health -= resource.damage
	if health <= 0:
		die()
		return

func die():
	get_parent().call_deferred("queue_free")

func freeze(duration: float):
	$FreezeTimer.wait_time = duration
	$FreezeTimer.start()
	# need to reduce speed

func _on_freeze_timer_timeout():
	pass # Replace with function body.
