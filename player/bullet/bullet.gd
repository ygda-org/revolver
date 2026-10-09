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
		return
	
