extends Area2D
class_name Wall


const SPEED = 50
var direction
var initialized: bool = false
var parried: bool = false

func _ready():
	Sfx.play(Sfx.Labels.MAKE_WALL)
	$RaycastPivot.scale.x = direction
	var tween = get_tree().create_tween()
	tween.set_parallel()
	tween.tween_property($CollisionShape2D, "position", Vector2(0,0), 1)
	tween.tween_property($CollisionShape2D.shape, "size", Vector2(8, 64), 1)

func _process(delta):
	if $Anim.is_playing():
		return
	position.x += direction * SPEED * delta
	if not $RaycastPivot/GroundCast.is_colliding():
		direction = 0.0

func _on_body_entered(body):
	if body is Player:
		body.hit(self)
	#elif body is TileMapLayer:
	#	direction = 0


func _on_timer_timeout():
	$Anim.play("end")
	var tween = get_tree().create_tween()
	tween.set_parallel()
	tween.tween_property($CollisionShape2D, "position", Vector2(0,28), 1)
	tween.tween_property($CollisionShape2D.shape, "size", Vector2(8, 8), 1)


func _on_anim_animation_finished():
	if initialized or parried:
		queue_free()
	else:
		initialized = true
