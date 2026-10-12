extends Area2D

var velocity: Vector2
const GRAVITY = 300
var parried: bool = false

const MAX_FALL_SPEED: float = 350

func _process(delta):
	if not parried:
		velocity.y = clampf(velocity.y + GRAVITY * delta, -MAX_FALL_SPEED, MAX_FALL_SPEED)
	position += velocity * delta
	$Anim.rotation = velocity.angle()
	$Anim.rotation += PI/2


func _on_body_entered(body):
	Sfx.play(Sfx.Labels.VOLCANO_BULLET_LAND)
	if body is Player and not parried:
		body.hit(self)
	var enemy_component = body.find_child("EnemyComponent")
	if enemy_component and parried:
		enemy_component.hit(GameState.BULLET_PARRY_DAMAGE)
	call_deferred("queue_free")


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
