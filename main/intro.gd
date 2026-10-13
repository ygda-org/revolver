extends Control

const ROLL_TIME = 2.5

# Called when the node enters the scene tree for the first time.
func _ready():
	var tween = get_tree().create_tween()
	tween.set_parallel()
	tween.tween_property($Logo, "position", Vector2(480-$Logo.size.x/2, 270-$Logo.size.y/2), ROLL_TIME)
	tween.tween_property($Logo, "rotation", 2*PI, ROLL_TIME)
	await tween.finished
	await get_tree().create_timer(0.4).timeout
	var tween2 = get_tree().create_tween()
	tween2.set_parallel()
	tween2.tween_property($Logo, "position", Vector2(960, 270-$Logo.size.y/2), ROLL_TIME)
	tween2.tween_property($Logo, "rotation", 4*PI, ROLL_TIME)
	await get_tree().create_timer(ROLL_TIME/2).timeout
	var tween3 = get_tree().create_tween()
	tween3.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.0), ROLL_TIME/2)
	tween3.tween_callback(queue_free)
