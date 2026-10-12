extends Camera2D

var target_position: Vector2

func _process(delta):
	global_position = global_position.lerp(target_position, delta)
