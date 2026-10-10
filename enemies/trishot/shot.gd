extends Area2D

const SPEED = 80

var direction: Vector2

func _ready():
	rotation = direction.angle()

func _process(delta):
	position += direction * SPEED * delta

func _on_body_entered(body):
	if body is Player:
		body.hit(self)
	call_deferred("queue_free")


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
