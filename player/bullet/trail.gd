extends Line2D

@export var length: float = 7
var point: Vector2


func _process(delta):
	point = get_parent().global_position
	add_point(point)
	while get_point_count()>length:
		remove_point(0)
