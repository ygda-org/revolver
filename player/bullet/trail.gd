extends Line2D

@export var length: int = 7
@export var lighting_length: int = 7
var point: Vector2

func _ready():
	$Lighting.width_curve = width_curve
	await get_tree().process_frame
	var transparent_color: Color = default_color - Color(0.0, 0.0, 0.0, 1.0)
	$Lighting.texture.gradient.set_color(0, transparent_color)
	$Lighting.texture.gradient.set_color(1, default_color - Color(0,0,0,0.8))
	$Lighting.texture.gradient.set_color(2, transparent_color)
	

func _process(delta):
	global_position = Vector2.ZERO
	point = get_parent().global_position
	add_point(point)
	while get_point_count()>length: 
		remove_point(0)
	$Lighting.add_point(point)
	while $Lighting.get_point_count()>lighting_length: 
		$Lighting.remove_point(0)
