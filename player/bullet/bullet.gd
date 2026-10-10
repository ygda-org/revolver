extends Area2D
class_name PlayerBullet

var direction: Vector2
var resource: BulletResource

var effect_methods = {
	BulletResource.effects.FREEZE: Callable(freeze)
}

var thing_i_hit: EnemyComponent

func _process(delta):
	if direction:
		position += direction * resource.speed * delta

func _on_body_entered(body: PhysicsBody2D):
	var enemy_component: EnemyComponent = body.find_child("EnemyComponent")
	if not enemy_component:
		call_deferred("queue_free")
		return
	enemy_component.hit(resource)
	thing_i_hit = enemy_component
	if resource.effect in effect_methods:
		effect_methods[resource.effect].call()
	call_deferred("queue_free")

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

# effect methods

func freeze():
	thing_i_hit.freeze(resource.effect_strength)
