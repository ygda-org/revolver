extends Node2D
class_name EnemyComponent

@export var health: int = 50

func hit(resource: BulletResource):
	health -= resource.damage
	if health <= 0:
		die()
		return
	

func die():
	pass
