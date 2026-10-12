extends Area2D

var speed = 115
var parried: bool = false

var direction: Vector2

func _process(delta):
	#rotation = direction.angle()
	position += direction * speed * delta

func _on_body_entered(body):
	if body is Player and not parried:
		body.hit(self)
	var enemy_component = body.find_child("EnemyComponent")
	if enemy_component and parried:
		enemy_component.hit(GameState.BULLET_PARRY_DAMAGE)
	call_deferred("queue_free")


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
