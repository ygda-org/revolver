extends Node2D

class_name BulletUI

@onready var pivot : Node2D = $SubViewportContainer/SubViewport/Pivot

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func spin():
	var tween := get_tree().create_tween()
	tween.tween_property(pivot, "rotation_degrees", -60, (5.0/32))
	tween.tween_property(pivot, "rotation_degrees", 0, 0)

func render_bullets():
	for i : BulletResource in GameState.active_barrel:
		i.outline_color
