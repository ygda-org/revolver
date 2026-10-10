extends Area2D

const SPEED = 55

var direction: Vector2

func _process(delta):
	position += direction * SPEED * delta

func _on_body_entered(body):
	if body is Player:
		body.hit()
	call_deferred("queue_free")


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
