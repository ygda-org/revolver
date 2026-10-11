extends Area2D

var velocity: Vector2
const GRAVITY = 300
var parried: bool = false

func _process(delta):
	velocity.y += GRAVITY * delta
	position += velocity * delta


func _on_body_entered(body):
	if body is Player:
		body.hit(self)
	var enemy_component = body.find_child("EnemyComponent")
	if enemy_component and parried:
		enemy_component.hit(GameState.BULLET_PARRY_DAMAGE)
	call_deferred("queue_free")


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
