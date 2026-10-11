extends Area2D

const SPEED = 50
var direction

func _ready():
	$RaycastPivot.scale.x = direction

func _process(delta):
	position.x += direction * SPEED * delta
	if not $RaycastPivot/GroundCast.is_colliding():
		direction = 0.0

func _on_body_entered(body):
	if body is Player:
		body.hit(self)
	elif body is TileMapLayer:
		direction = 0


func _on_timer_timeout():
	queue_free()
