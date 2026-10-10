extends Area2D
class_name PlayerBullet

var direction: Vector2
var resource: BulletResource

func _process(delta):
	if direction:
		position += direction * resource.speed * delta

func _on_body_entered(body: PhysicsBody2D):
	var enemy_component: EnemyComponent = body.find_child("EnemyComponent")
	if not enemy_component:
		call_deferred("queue_free")
		return
	enemy_component.hit(resource)
	call_deferred("queue_free")


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
