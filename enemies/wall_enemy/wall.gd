extends Area2D

const SPEED = 50
var direction
var initialized: bool = false

func _ready():
	$RaycastPivot.scale.x = direction

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
	$CollisionShape2D.disabled = true


func _on_anim_animation_finished():
	if initialized:
		queue_free()
	else:
		$CollisionShape2D.disabled = false
		initialized = true
